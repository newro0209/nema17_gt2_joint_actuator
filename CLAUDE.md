# CLAUDE.md

This repository contains a parametric OpenSCAD design for a NEMA17 GT2 belt robot joint actuator.

## Layout

- `cad/lib/params.scad` is the single source of truth for dimensions, fits, and render defaults.
- `cad/lib/*.scad` contains reusable modules for GT2 pulleys, plates, printed parts, utilities, and assembly visualization.
- `cad/src/*.scad` contains one printable part per file.
- `cad/src/assembly.scad` is preview-only and should not be exported as a printable STL.
- `cad/render.ps1` exports printable parts into `cad/build/`.
- `joint_actuator.scad` is a compatibility entry point for the legacy `PART` selector workflow.

## Commands

```powershell
.\cad\render.ps1
.\cad\render.ps1 motor_plate
```

Manual example:

```powershell
& "C:\Program Files\OpenSCAD\openscad.exe" -o cad\build\motor_plate.stl --export-format binstl cad\src\motor_plate.scad
```

## Design Rules

- Keep dimensions in `cad/lib/params.scad`; do not hard-code shared dimensions in part files.
- Keep `cad/src/assembly.scad` preview-only.
- The default belt is GT2 6 mm closed-loop 150 mm with `center_distance = 32.5`.
- The output shaft uses 608ZZ bearings. Tune `bearing_press_fit` and `bearing_snap_lip` for the actual printer before relying on the fit.
- The motor plate corner towers are part of the motor plate body conceptually; preserve their alignment with the plate outline and output pulley keepout.
