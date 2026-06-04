// =============================================================================
//  parts.scad  -  Printed mechanical parts: output shaft, arm.
//                 (출력용 기계 부품: 출력 샤프트, 암)
//  Depends on shaft / arm parameters and through() from util.scad.
//  (util.scad의 샤프트 / 암 파라미터 및 through()에 의존합니다)
// =============================================================================

// World-Z of the bearing outer faces (where the shaft shoulder seats).
// (베어링 외부 면의 월드 Z 좌표 - 샤프트 숄더가 안착되는 위치)
function lower_outer_z() = -plate_th;              // motor-side bearing outer face (모터 쪽 베어링 외부 면)
function upper_outer_z() = plate_gap + bearing_w;  // arm-side bearing outer face (암 쪽 베어링 외부 면)

module output_shaft() {
    z0     = lower_outer_z();                             // shaft bottom flush with motor-side bearing outer face (모터 쪽 베어링 외부 면과 수평이 되는 샤프트 바닥)
    sh_lo  = upper_outer_z() - z0;                        // shoulder seats on the upper bearing outer face (상단 베어링 외부 면에 안착되는 숄더)
    L      = (upper_outer_z() + shaft_shoulder_h + shaft_overhang) - z0;
    flat0  = (lower_outer_z() + bearing_w) - z0;          // pulley/D-cut zone: between the two gap faces (풀리/D-컷 영역: 두 갭 면 사이)
    flat1  = (upper_outer_z() - bearing_w) - z0;
    // Self-supporting shoulder: flat seat (toward the bearing) + a 45-deg conical
    // (서포트가 필요 없는 숄더: 평평한 안착면 (베어링 쪽) + 45도 원뿔형)
    // lead-out on top. Print the shaft OUTPUT-END-DOWN so the seat face points up
    // (상단 리드아웃. 출력단이 아래를 향하도록 샤프트를 출력하여 안착면이 위를 향하게 하고)
    // (a flat shelf) and the cone is the only downward face -> 45 deg, no support.
    // (평평한 선반 형태, 원뿔이 유일하게 아래를 향하는 면이 되도록 함 -> 45도 경사로 서포트 불필요)
    taper  = (shaft_shoulder_d - output_bore) / 2;        // 45-deg radial step (45도 반경 방향 단차)
    difference() {
        union() {
            cylinder(d = output_bore, h = L, $fn = 72);
            // integral shoulder: seats on the upper bearing inner race -> blocks axial slide
            // (일체형 숄더: 상단 베어링 내륜에 안착됨 -> 축방향 미끄러짐 방지)
            translate([0, 0, sh_lo]) {
                cylinder(d = shaft_shoulder_d, h = shaft_shoulder_h - taper, $fn = 64);
                translate([0, 0, shaft_shoulder_h - taper])
                    cylinder(d1 = shaft_shoulder_d, d2 = output_bore,
                             h = taper, $fn = 64);
            }
        }
        // D-cut flat for the output-pulley set screw (gap/pulley engagement zone)
        // (출력 풀리 무두볼트를 위한 D-컷 평면 (갭/풀리 맞물림 영역))
        translate([output_bore / 2 - shaft_flat_depth, -output_bore, flat0])
            cube([output_bore, 2 * output_bore, flat1 - flat0]);
    }
}

module output_arm() {
    difference() {
        union() {
            linear_extrude(arm_th)
                soft_outline2d(0.7)
                    hull() {
                        circle(d = arm_hub_d + 1.2, $fn = 80);
                        translate([arm_len, 0]) circle(d = 11.5, $fn = 48);
                    }
        }
        through(output_bore + bore_clearance, arm_th);
        translate([arm_len, 0, 0]) through(arm_end_hole_d, arm_th, 32);
        if (set_screw_d > 0)
            translate([0, 0, arm_th / 2]) rotate([-90, 0, 0])
                cylinder(d = set_screw_d, h = arm_hub_d, $fn = 24);
    }
}
