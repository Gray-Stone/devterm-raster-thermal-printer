#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}"
BUILD_BIN="${SRC_DIR}/rastertocpi"

FILTER_DST="/usr/lib/cups/filter/rastertocpi"
PPD_SRC="${SRC_DIR}/cpi58.ppd"
MODEL_DST="/usr/share/cups/model/clockworkpi/cpi58.ppd"

# Optional queue wiring:
# - Leave QUEUE_NAME empty (default) to install filter+model only.
# - Set QUEUE_NAME=<queue> to also install queue PPD + defaults for that queue.
QUEUE_NAME="${QUEUE_NAME:-}"
PPD_DST=""
if [[ -n "${QUEUE_NAME}" ]]; then
  PPD_DST="/etc/cups/ppd/${QUEUE_NAME}.ppd"
fi

BACKUP_DIR="/var/backups/tprint-rastertocpi"
STAMP="$(date +%Y%m%d-%H%M%S)"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

require_cmd gcc
require_cmd cups-config
require_cmd sudo
require_cmd systemctl
require_cmd lpoptions

if [[ ! -f "${SRC_DIR}/rastertocpi.c" ]]; then
  echo "source not found: ${SRC_DIR}/rastertocpi.c" >&2
  exit 1
fi
if [[ ! -f "${PPD_SRC}" ]]; then
  echo "ppd not found: ${PPD_SRC}" >&2
  exit 1
fi

echo "Building rastertocpi..."
(
  cd "${SRC_DIR}"
  gcc rastertocpi.c -o rastertocpi -I /usr/include \
    $(cups-config --cflags) $(cups-config --image --libs)
)

echo "Backing up current filter and PPD to ${BACKUP_DIR}/${STAMP}..."
sudo mkdir -p "${BACKUP_DIR}/${STAMP}"
if [[ -f "${FILTER_DST}" ]]; then
  sudo cp -a "${FILTER_DST}" "${BACKUP_DIR}/${STAMP}/rastertocpi"
fi
if [[ -n "${PPD_DST}" ]] && sudo test -f "${PPD_DST}"; then
  sudo cp -a "${PPD_DST}" "${BACKUP_DIR}/${STAMP}/${QUEUE_NAME}.ppd"
fi

echo "Installing filter and PPD..."
sudo install -m 0755 -o root -g root "${BUILD_BIN}" "${FILTER_DST}"
sudo install -d -m 0755 -o root -g root /usr/share/cups/model/clockworkpi
sudo install -m 0644 -o root -g root "${PPD_SRC}" "${MODEL_DST}"
if [[ -n "${PPD_DST}" ]]; then
  sudo install -m 0644 -o root -g lp "${PPD_SRC}" "${PPD_DST}"
fi

echo "Restarting CUPS..."
sudo systemctl restart cups

if [[ -n "${QUEUE_NAME}" ]]; then
  if lpstat -p "${QUEUE_NAME}" >/dev/null 2>&1; then
    echo "Applying queue defaults for stable spacing on ${QUEUE_NAME}..."
    lpoptions -p "${QUEUE_NAME}" \
      -o FeedWhere=None \
      -o BlankSpace=False \
      -o TrimMode=Strong \
      -o orientation-requested=3 \
      -o print-scaling=none || true
    if command -v lpadmin >/dev/null 2>&1; then
      sudo lpadmin -p "${QUEUE_NAME}" \
        -o FeedWhere=None \
        -o BlankSpace=False \
        -o TrimMode=Strong \
        -o orientation-requested-default=3 \
        -o print-scaling-default=none || true
    fi
  else
    echo "Skipping queue defaults: queue '${QUEUE_NAME}' not found."
  fi
else
  echo "QUEUE_NAME not set: skipped queue PPD install/defaults."
fi

echo "Done. Backups: ${BACKUP_DIR}/${STAMP}"
