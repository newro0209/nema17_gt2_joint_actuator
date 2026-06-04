// =============================================================================
//  NEMA17 (SF2424) GT2 Belt Robot Joint Actuator  -  3:1 reduction (20T -> 60T)
// =============================================================================
//  Entry point. Open THIS file in OpenSCAD and tune values below (or via
//  Window > Customizer). Implementation lives in lib/*.scad.
//
//  Design philosophy: print the structural parts (pulleys, shaft, plates), but
//  use REAL 608ZZ ball bearings from the start (use_bearings = true) and a
//  PURCHASED GT2 belt. Optionally swap the printed shaft for an 8mm ground shaft.
//  Belt is a bought GT2 part (never printed). GT2 6mm closed-loop 80T = 160mm.
// =============================================================================

/* [ What to render / export ] */
// Pick one. Export each as its own STL.
PART = "assembly"; // [assembly, input_pulley, output_pulley, motor_plate, support_plate, output_shaft, output_collar, output_bushing, spacer, output_arm]

/* [ Bearing selection ] */
// true  = real 608ZZ bearings (22 OD x 7 W x 8 ID) pressed into the plates. (default)
// false = fully printed plain journal bore (legacy phase-1 test only).
use_bearings = true;

/* [ Clearances / fit  (0.28mm Standard @ SparkX i7, 0.4 nozzle) ] */
boolean_eps       = 0.02;  // CSG overlap only - keep tiny (avoids coplanar faces)
bore_clearance    = 0.20;  // printed bore -> shaft/screw slip fit (diametral)
tooth_clearance   = 0.06;  // GT2 groove widening for belt mesh
journal_clearance = 0.30;  // printed plain-bearing running fit (legacy phase-1)
bearing_press_fit = 0.05;  // 608ZZ press into plate pocket (diametral, snug)

/* [ GT2 belt ] */
belt_pitch       = 2.0;    // GT2 = 2mm pitch
belt_pld         = 0.254;  // GT2 pitch line distance (pulley OD = PD - 2*PLD)
belt_width       = 6.0;    // 6mm GT2 belt  ("6M" in TP-5-6M-20T-16H)
belt_thickness   = 1.4;    // for belt visualisation only

/* [ Pulleys ] */
input_teeth      = 20;     // motor pulley
output_teeth     = 60;     // joint pulley  -> 3:1 reduction
input_bore       = 5.0;    // NEMA17 shaft diameter
output_bore      = 8.0;    // output shaft (= 608ZZ ID)
flange_t         = 1.2;    // flange thickness each side
flange_extra     = 1.9;    // radial flange beyond tooth OD (20T -> ~16mm flange)
input_hub_h      = 5.0;    // set-screw boss under flange
output_hub_h     = 6.0;
set_screw_d      = 3.2;    // M3 grub screw clearance (radial)

/* [ Geometry / center distance ] */
// Center distance between motor shaft and output shaft.
// Slotted motor mount allows +/- tension_travel/2 for belt tensioning.
center_distance  = 40.0;
tension_travel   = 10.0;   // slot length for motor (belt tension adjust)
plate_gap        = 22.0;   // clear distance between the two frame plates

/* [ NEMA17 motor (SF2424) ] */
motor_size       = 42.3;   // faceplate
motor_hole_pitch = 31.0;   // bolt circle (square pattern)
motor_screw_d    = 3.4;    // M3 clearance
motor_boss_d     = 24.0;   // 22mm pilot boss + clearance
motor_body_len   = 40.0;   // for visualisation only (verify your motor)

/* [ Frame plates / integrated posts ] */
// The motor plate prints with the 4 standoff posts as one integral part;
// the support plate is a flat lid that screws onto the post tops.
plate_th         = 5.0;
standoff_screw_d = 3.4;    // M3 clearance through the lid
post_od          = 9.0;    // integral standoff post outer diameter
post_pilot_d     = 2.6;    // M3 self-tap pilot bored into each post top
post_pilot_depth = 14.0;   // pilot/engagement depth from the post top
standoff_od      = 8.0;    // legacy separate spacer OD (PART="spacer")
// Skeletal (truss) frame - tune the open shape vs. filament/rigidity.
strut_w          = 8.0;    // width of the base truss struts joining the nodes
lid_strut_w      = 6.0;    // thinner struts for the reduced support lid (spider)
hub_collar       = 6.0;    // material ring around the bearing OD at the hub
boss_extra       = 3.0;    // post-boss diameter added beyond post_od
motor_pad_margin = 3.0;    // rounded-square margin around the NEMA17 footprint

/* [ Bearings / journal ] */
bearing_od       = 22.0;   // 608ZZ
bearing_w        = 7.0;
bearing_lip      = 2.0;    // outer retaining-lip width, radial (Ø = bearing_od - 2*this)

/* [ Bearing retention ] */
// plate_th (5) < bearing_w (7), so the hub is locally thickened toward the gap
// to host a real lip; struts/pad stay thin.  hub_h = bearing_w + bearing_lip_floor.
bearing_lip_floor = 1.5;   // axial material outboard of the bearing (the lip floor)
bearing_snap_lip  = 0.6;   // gap-side snap lip, radial (bearing clicks past on insert)
bearing_snap_h    = 1.0;   // height of the snap-lip ring (chamfered lead-in)

/* [ Printed shaft (phase 1) ] */
shaft_overhang   = 30.0;   // length sticking out past the support plate
shaft_flat_depth = 1.0;    // D-cut depth for set-screw grip

/* [ Output shaft retention ] */
// Positive axial lock: an integral shoulder seats on the upper bearing inner
// race; a printed set-screw collar clamps the lower bearing inner race.
shaft_shoulder_d = 12.0;   // shoulder OD (contacts 608 inner race, not the shield)
shaft_shoulder_h = 3.0;    // shoulder height
collar_od        = 16.0;   // set-screw collar outer diameter
collar_h         = 8.0;    // set-screw collar height
collar_below     = 2.0;    // clearance below the motor-side bearing for the collar

/* [ Printed bushing (phase 1 wear sleeve, optional) ] */
bushing_od       = 22.0;   // press into the 22mm bearing pocket
bushing_len      = 8.0;

/* [ Output arm (optional joint link) ] */
arm_len          = 40.0;
arm_th           = 6.0;
arm_hub_d        = 18.0;
arm_end_hole_d   = 4.0;

/* [ Quality ] */
$fa = 2;
$fs = 0.4;

// Standoff (frame tie) positions in the plate plane. Kept clear of pulleys/belt.
standoffs = [
    [-motor_size/2 - 3, -motor_size/2 + 3],
    [-motor_size/2 - 3,  motor_size/2 - 3],
    [ center_distance + 25, -15],
    [ center_distance + 25,  15]
];

// ---- Implementation (parameters above are shared into these via include) ----
include <lib/util.scad>
include <lib/gt2.scad>
include <lib/plates.scad>
include <lib/parts.scad>
include <lib/viz.scad>

// =============================================================================
//  Render selector
// =============================================================================
if      (PART == "assembly")       assembly();
else if (PART == "input_pulley")   input_pulley();
else if (PART == "output_pulley")  output_pulley();
else if (PART == "motor_plate")    motor_plate();
else if (PART == "support_plate")  support_plate();
else if (PART == "output_shaft")   output_shaft();
else if (PART == "output_collar")  output_collar();
else if (PART == "output_bushing") output_bushing();
else if (PART == "spacer")         spacer();
else if (PART == "output_arm")     output_arm();
