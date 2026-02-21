# devterm-raster-thermal-printer

Minimal standalone repo for the DevTerm thermal printer CUPS driver.

This repo starts from ClockworkPi's driver files and is intended to evolve via commits for fixes.

## Current Driver Behavior

Current default behavior in `rastertocpi.c`:

- forced single-line raster blocks (`y = 1`)
- optional strong whitespace trim mode
  - trims leading and trailing blank rows
  - preserves blank rows inside content
  - detects white rows encoded as either `0x00` or `0xFF`
- no per-line pacing delay (`RASTER_LINE_DELAY_US = 0`)
- SIGTERM handler type fixed for modern GCC (`void (*)(int)`)

Current default behavior in `cpi58.ppd`:

- media sizes exposed as 48mm width presets
- `TrimMode` option:
  - `Strong` (default): trim top/bottom whitespace in filter
  - `Off`: print full page height

## Base Files

- `rastertocpi.c`
- `cpi58.ppd`
- `Makefile`
- `README.devterm.upstream.md` (copied upstream README)
- `install_patched_rastertocpi.sh`

## Upstream Origin

ClockworkPi DevTerm:

- https://raw.githubusercontent.com/clockworkpi/DevTerm/main/Code/devterm_thermal_printer_cups/rastertocpi.c
- https://raw.githubusercontent.com/clockworkpi/DevTerm/main/Code/devterm_thermal_printer_cups/cpi58.ppd

Reference SHA snapshots used for initial import:

- `rastertocpi.c`: `f6126fdbc340cc42cd6f4a62052c86fb4bf3c4f1`
- `cpi58.ppd`: `1af02c4acdf2cd72ec8a544953a53c403681c77f`

## Build + Install

Install script now supports two modes.

### 1) Driver-Only Install (recommended on clients)

```bash
./install_patched_rastertocpi.sh
```

This installs:

- `/usr/lib/cups/filter/rastertocpi`
- `/usr/share/cups/model/clockworkpi/cpi58.ppd`

It does **not** modify any queue by default.

### 2) Queue-Aware Install (optional)

```bash
QUEUE_NAME=portterm ./install_patched_rastertocpi.sh
```

If queue exists, script also:

- installs queue PPD to `/etc/cups/ppd/<QUEUE_NAME>.ppd`
- applies defaults:
  - `FeedWhere=None`
  - `BlankSpace=False`
  - `TrimMode=Strong`
  - `orientation-requested=3`
  - `print-scaling=none`

## Recommended Queue Topology

For client machines with local custom filter:

- local queue uses local `rastertocpi` + local `cpi58.ppd`
- queue device URI points to server raw queue:
  - `ipp://portterm/printers/devterm_raw`

This avoids double filtering.

## Quick Verify

Check option presence:

```bash
lpoptions -p <queue> -l | rg "TrimMode|PageSize|FeedWhere|BlankSpace"
```

Check active queue PPD:

```bash
rg -n "TrimMode" /etc/cups/ppd/<queue>.ppd
```

## Known Good CLI Print Example

For a 45x20 mm PDF label:

```bash
lp -d <queue> \
  -o orientation-requested=3 \
  -o print-scaling=none \
  -o media=Custom.45x20mm \
  -o TrimMode=Strong \
  -o BlankSpace=False \
  -o FeedWhere=None \
  label.pdf
```
