# devterm-raster-thermal-printer

Minimal standalone repo for the DevTerm thermal printer CUPS driver.

This repo starts from ClockworkPi's driver files and is intended to evolve via commits for fixes.

Current default behavior in this repo:

- forced single-line raster blocks (`y = 1`)
- no in-page whitespace skipping/compression
- no per-line pacing delay (`RASTER_LINE_DELAY_US = 0`)
- stable queue defaults applied on install:
  - `FeedWhere=None`
  - `BlankSpace=True`

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

```bash
./install_patched_rastertocpi.sh
```
