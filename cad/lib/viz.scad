// =============================================================================
//  viz.scad  -  Assembly visualisation only (motor, belt, bearings, labels).
//               (어셈블리 미리보기 전용 (모터, 벨트, 베어링, 라벨 포함))
//  Not exported as parts. Depends on parameters from params.scad,
//  (부품으로 출력되지 않습니다. params.scad의 파라미터와)
//  pitch_radius() from gt2.scad, ring3d() from util.scad, and the part modules.
//  (gt2.scad의 pitch_radius(), util.scad의 ring3d(), 그리고 부품 모듈들에 의존합니다.)
// =============================================================================

module nema17_body() {
    color([0.02, 0.02, 0.018])
        translate([-motor_size/2, -motor_size/2, -plate_th - motor_body_len])
            cube([motor_size, motor_size, motor_body_len]);
    color("Silver")  // shaft (샤프트)
        translate([0, 0, -plate_th])
            cylinder(d = input_bore, h = plate_th + plate_gap * 0.5, $fn = 30);
}

module belt_viz() {
    pr_in  = pitch_radius(input_teeth);
    pr_out = pitch_radius(output_teeth);
    z = plate_gap / 2 - belt_width / 2;
    color([0.15, 0.15, 0.15, 0.85])
    translate([0, 0, z]) linear_extrude(belt_width)
        difference() {
            offset(belt_thickness) hull() {
                circle(r = pr_in,  $fn = 80);
                translate([center_distance, 0]) circle(r = pr_out, $fn = 120);
            }
            hull() {
                circle(r = pr_in,  $fn = 80);
                translate([center_distance, 0]) circle(r = pr_out, $fn = 120);
            }
        }
}

// 608ZZ ball bearing (visual): 22 OD x 8 ID x 7 W, metal-shielded faces.
// (608ZZ 볼 베어링 (시각용): 외경 22 x 내경 8 x 폭 7, 금속 실드 적용.)
// Base at z=0, axis +Z. Pressed into each plate's output pocket.
// (밑면은 z=0, 축은 +Z. 각 플레이트의 출력 포켓에 억지 끼워맞춤됨.)
module bearing608_viz() {
    o_seat = bearing_od - 4;        // outer race inner edge (외륜 안쪽 모서리)
    i_seat = output_bore + 3;       // inner race outer edge (내륜 바깥쪽 모서리)
    sh     = 0.6;                   // shield plate thickness (실드 플레이트 두께)
    color([0.68, 0.72, 0.76]) {
        ring3d(bearing_od, o_seat, bearing_w);   // outer race (외륜)
        ring3d(i_seat, output_bore, bearing_w);  // inner race (내륜)
    }
    color([0.88, 0.90, 0.88]) {                   // metal shields, both faces (금속 실드, 양면)
        translate([0, 0, 0])              ring3d(o_seat + 0.2, i_seat - 0.2, sh);
        translate([0, 0, bearing_w - sh]) ring3d(o_seat + 0.2, i_seat - 0.2, sh);
    }
    color([0.18, 0.20, 0.22]) {
        translate([0, 0, bearing_w * 0.5 - 0.15])
            ring3d(o_seat + 0.1, i_seat - 0.1, 0.3);
    }
}

module screw_head_viz(d = 5.8, h = 1.15) {
    color([0.72, 0.74, 0.72])
        cylinder(d = d, h = h, $fn = 40);
    color([0.10, 0.10, 0.10])
        translate([0, 0, h - 0.06])
            linear_extrude(0.08)
                rounded_rect2d([d * 0.62, d * 0.14], d * 0.06);
}

// Floating part-name labels (assembly view only, not part of any STL).
// (떠있는 부품 이름 라벨 (어셈블리 미리보기 전용, STL에 포함되지 않음).)
// Text stands up in the XZ plane so it reads in OpenSCAD's default view.
// (텍스트가 XZ 평면에 서 있어 OpenSCAD의 기본 뷰에서 읽기 쉽습니다.)
module label(txt, pos, sz = 3.5) {
    translate(pos) rotate([90, 0, 0])
        color("Black") linear_extrude(0.4)
            text(txt, size = sz, halign = "center", valign = "center",
                 font = "Liberation Sans:style=Bold");
}

module assembly_labels() {
    yf = -motor_size/2 - 9;   // common front plane so labels never hide behind parts (라벨이 부품 뒤에 가려지지 않도록 공통 전면 평면 사용)
    label("NEMA17",        [0, yf, -plate_th - motor_body_len/2]);
    label("motor_plate",   [-26, yf, -plate_th/2]);
    label("support_plate", [-26, yf, plate_gap + plate_th/2]);
    label("input_pulley",  [0, yf, plate_gap + 12]);
    label("output_pulley", [center_distance, yf, plate_gap + 12]);
    label("output_shaft",  [center_distance, yf, upper_outer_z() + shaft_overhang - 4]);
    label("post",          [center_distance + 18, yf, plate_gap + 6]);
    label("GT2 belt",      [center_distance/2, yf, plate_gap/2]);
    label("608ZZ",         [center_distance, yf, upper_outer_z() - bearing_w/2]);
}

module assembly() {
    // motor plate (base + integral posts): gap-facing side at +Z, pocket toward gap
    // (모터 플레이트 (하단 + 일체형 포스트): 갭 방향 면이 +Z, 포켓은 갭 방향을 향함)
    color([0.94, 0.92, 0.86]) translate([0, 0, -plate_th]) motor_plate_body();
    color([0.94, 0.92, 0.86]) translate([0, 0, -plate_th]) motor_posts();

    // support lid at the far side of the gap, flipped so its pocket faces the gap
    // (갭 반대편에 있는 서포트 상단부, 포켓이 갭 방향을 향하도록 뒤집힘)
    color([0.94, 0.92, 0.86])
        translate([0, 0, plate_gap + plate_th]) rotate([180, 0, 0]) support_plate();

    nema17_body();

    // pulleys, toothed centre aligned to gap centre
    // (풀리, 톱니 중심이 갭 중심에 맞춰짐)
    pulley_z = plate_gap/2 - (flange_t + belt_width/2);
    color([1.0, 0.28, 0.06]) translate([0, 0, pulley_z]) input_pulley();
    // output pulley installs HUB-DOWN so its hub clears the shaft's inboard shoulder at the gap top
    // (출력 풀리는 허브가 아래로 향하게 조립 -> 갭 상단의 샤프트 안쪽 숄더를 피함)
    color([1.0, 0.28, 0.06])
        translate([center_distance, 0, plate_gap/2 + (flange_t + belt_width/2)])
            rotate([180, 0, 0]) output_pulley();

    color("Silver")
        translate([center_distance, 0, lower_outer_z()]) output_shaft();

    // (standoff posts are now integral to the motor plate, drawn above)
    // (스탠드오프 포스트는 이제 모터 플레이트와 일체형이므로 위에서 그려짐)

    // 608ZZ bearings seated in each plate's output pocket (gap-facing side)
    // (각 플레이트의 출력 포켓(갭 방향)에 안착된 608ZZ 베어링)
    color([.6, .2, .2]) translate([center_distance, 0, lower_outer_z()])               bearing608_viz();  // motor plate (모터 플레이트)
    color([.6, .2, .2]) translate([center_distance, 0, upper_outer_z() - bearing_w])   bearing608_viz();  // support plate (서포트 플레이트)

    // Visible fastener heads, styled like the reference prototype photos.
    // (참조 프로토타입 사진과 비슷한 스타일로 표시된 조립 나사 헤드)
    for (p = standoffs)
        translate([p[0], p[1], plate_gap + plate_th + 0.02])
            screw_head_viz();
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * motor_hole_pitch / 2, sy * motor_hole_pitch / 2, 0.02])
            screw_head_viz(5.4, 1.0);

    belt_viz();
    if (show_labels) assembly_labels();
}
