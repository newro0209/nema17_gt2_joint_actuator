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
    seat   = upper_outer_z() - bearing_w - z0;            // shoulder seats on the upper bearing GAP-side (inner) face (상단 베어링 갭쪽(안쪽) 면에 안착되는 숄더)
    L      = (upper_outer_z() + shaft_overhang) - z0;     // output stub reaches shaft_overhang above the upper bearing (출력 스텁은 상단 베어링 위로 shaft_overhang 만큼 뻗음)
    flat0  = (lower_outer_z() + bearing_w) - z0;          // D-cut starts at the lower gap face (D-컷은 하부 갭 면부터 시작)
    flat1  = seat - shaft_shoulder_h;                     // ...up to just below the inboard shoulder (seat face stays full) (...안쪽 숄더 바로 아래까지 (안착면 보존))
    // Inboard shoulder = positive PULL-OUT stop: its flat top seats UP against the
    // (안쪽 숄더 = pull-out 기계적 정지: 평평한 윗면이 상단 베어링 내륜 갭쪽 면을 위로 받침)
    // upper bearing inner race; the underside is a 45° self-supporting cone.
    // (아랫면은 45° 자립 원뿔.)
    // Print MOTOR-END-DOWN (motor end on the bed): the cone is the only downward
    // (모터단을 베드로 향하게 출력: 원뿔이 유일한 아래보기 면 -> 서포트 불필요)
    // face. The output pulley installs HUB-DOWN to clear this shoulder.
    // (출력 풀리는 이 숄더를 피하도록 허브가 아래로 가게 조립.)
    taper  = (shaft_shoulder_d - output_bore) / 2;        // 45-deg radial step (45도 반경 방향 단차)
    difference() {
        union() {
            // chamfered motor-end tip (bed side): lead-in into the lower bearing + elephant-foot relief.
            // (모따기된 모터단 끝(베드 쪽): 하부 베어링 진입 리드인 + 엘리펀트풋 완화.)
            cylinder(d1 = output_bore - 2 * print_chamfer, d2 = output_bore,
                     h = print_chamfer, $fn = 72);
            translate([0, 0, print_chamfer])
                cylinder(d = output_bore, h = L - print_chamfer, $fn = 72);
            // integral inboard shoulder: seats on the upper bearing inner race -> blocks pull-out
            // (일체형 안쪽 숄더: 상단 베어링 내륜에 안착됨 -> pull-out(빠짐) 정지)
            translate([0, 0, seat - shaft_shoulder_h]) {
                cylinder(d1 = output_bore, d2 = shaft_shoulder_d, h = taper, $fn = 64);
                translate([0, 0, taper])
                    cylinder(d = shaft_shoulder_d, h = shaft_shoulder_h - taper, $fn = 64);
            }
        }
        // D-cut flat for the output-pulley set screw (gap zone, below the shoulder)
        // (출력 풀리 무두볼트를 위한 D-컷 평면 (갭 영역, 숄더 아래))
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
        chamfer_dn(output_bore + bore_clearance, print_chamfer);
        translate([0, 0, arm_th]) chamfer_up(output_bore + bore_clearance, print_chamfer);
        translate([arm_len, 0, 0]) through(arm_end_hole_d, arm_th, 32);
        if (set_screw_d > 0)
            translate([0, 0, arm_th / 2]) rotate([-90, 0, 0])
                cylinder(d = set_screw_d, h = arm_hub_d, $fn = 24);
    }
}
