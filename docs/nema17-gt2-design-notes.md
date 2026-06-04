# NEMA17 GT2 Joint Actuator Design Notes

## Current Defaults

- Reduction: 3:1 using 20T input and 60T output GT2 pulleys.
- Belt: GT2, 6 mm wide, 150 mm closed loop.
- Bearings: two 608ZZ bearings, 22 OD x 8 ID x 7 W.
- Output shaft: 8 mm nominal.

## Fit Notes

- `bearing_press_fit` is diametral interference. A positive value makes the pocket smaller.
- `bearing_snap_lip` is intentionally modest for FDM parts.
- Test bearing pockets before printing the full frame if the printer/material has not been characterized.
