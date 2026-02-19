# devterm-raster-thermal-printer

Minimal standalone repo for the DevTerm thermal CUPS raster driver files.

## Source Base

Copied from ClockworkPi DevTerm upstream:

- `Code/devterm_thermal_printer_cups/rastertocpi.c`
- `Code/devterm_thermal_printer_cups/cpi58.ppd`
- `Code/devterm_thermal_printer_cups/Makefile`
- `Code/devterm_thermal_printer_cups/README.md`

Upstream references:

- https://raw.githubusercontent.com/clockworkpi/DevTerm/main/Code/devterm_thermal_printer_cups/rastertocpi.c
- https://raw.githubusercontent.com/clockworkpi/DevTerm/main/Code/devterm_thermal_printer_cups/cpi58.ppd

## Layout

- `upstream/` - original DevTerm driver source files
- `install_patched_rastertocpi.sh` - local build/install helper

## Build + Install

```bash
./install_patched_rastertocpi.sh
```
