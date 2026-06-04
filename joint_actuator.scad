// =============================================================================
//  NEMA17 (SF2424) GT2 Belt Robot Joint Actuator  -  3:1 reduction (20T -> 60T)
// =============================================================================
//  Compatibility entry point. The canonical CAD layout lives under cad/.
//  Open this file in OpenSCAD if you want the legacy PART selector workflow.
// =============================================================================

include <cad/lib/params.scad>
include <cad/lib/util.scad>
include <cad/lib/gt2.scad>
include <cad/lib/plates.scad>
include <cad/lib/parts.scad>
include <cad/lib/viz.scad>

if      (PART == "assembly")       assembly();
else if (PART == "input_pulley")   color("Orange") input_pulley();
else if (PART == "output_pulley")  color("Tomato") output_pulley();
else if (PART == "motor_plate")    color([0.94, 0.92, 0.86]) motor_plate();
else if (PART == "support_plate")  color([0.94, 0.92, 0.86]) support_plate();
else if (PART == "output_shaft")   color("Silver") output_shaft();
else if (PART == "output_collar")  color([0.05, 0.25, 0.85]) output_collar();
else if (PART == "output_bushing") color([0.82, 0.46, 0.16]) output_bushing();
else if (PART == "spacer")         color("LightSlateGray") spacer();
else if (PART == "output_arm")     color("LightSteelBlue") output_arm();
