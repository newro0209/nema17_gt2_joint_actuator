// =============================================================================
//  gt2.scad  -  GT2 (2GT) tooth profile, pitch math, and toothed pulleys.
//               (GT2 (2GT) 치형, 피치 계산, 톱니 풀리)
//  Depends on belt_* / pulley parameters from params.scad and on through()
//  from util.scad.
//  (params.scad의 belt_* / pulley 파라미터와 util.scad의 through()에 의존합니다)
// =============================================================================

// Gates 2GT, one tooth, centred at origin, tip toward +Y.
// (Gates 2GT, 원점에 맞춰진 단일 치형, 끝단은 +Y 방향)
GT2_2mm_tooth = [
    [ 0.747183, -0.500000],
    [ 0.747183,  0.000000],
    [ 0.647876,  0.037218],
    [ 0.598311,  0.130528],
    [ 0.578031,  0.238423],
    [ 0.547627,  0.323574],
    [ 0.504833,  0.385838],
    [ 0.451285,  0.434776],
    [ 0.388525,  0.471447],
    [ 0.318112,  0.497275],
    [ 0.241601,  0.513758],
    [ 0.160553,  0.522438],
    [ 0.076528,  0.523938],
    [-0.076528,  0.523938],
    [-0.160553,  0.522438],
    [-0.241601,  0.513758],
    [-0.318112,  0.497275],
    [-0.388525,  0.471447],
    [-0.451285,  0.434776],
    [-0.504833,  0.385838],
    [-0.547627,  0.323574],
    [-0.578031,  0.238423],
    [-0.598311,  0.130528],
    [-0.647876,  0.037218],
    [-0.747183,  0.000000],
    [-0.747183, -0.500000]
];

function pitch_radius(teeth) = teeth * belt_pitch / (2 * PI);
function pulley_od(teeth)    = 2 * (pitch_radius(teeth) - belt_pld);

// 2D pulley cross section: solid disk at land radius minus GT2 grooves.
// (2D 풀리 단면: 랜드 반지름의 꽉 찬 디스크에서 GT2 홈을 뺀 형태)
module gt2_pulley_2d(teeth) {
    pr = pitch_radius(teeth);
    difference() {
        circle(r = pr - belt_pld, $fn = max(64, teeth * 6));
        for (i = [0 : teeth - 1])
            rotate(i * 360 / teeth)
                translate([0, pr - 0.5])      // place groove mouth at pitch radius (피치 반지름에 홈 입구 배치)
                    rotate(180)               // flip tooth tip toward centre (치형 끝단을 중심부로 뒤집기)
                        offset(delta = tooth_clearance)
                            polygon(GT2_2mm_tooth);
    }
}

// 3D pulley with flanges, set-screw hub and bore.
// (플랜지, 무두볼트(세트스크류) 허브 및 보어가 있는 3D 풀리)
module gt2_pulley(teeth, bore, hub_h) {
    od = pulley_od(teeth);
    fd = od + 2 * flange_extra;
    hub_d = max(bore + 6, od * 0.6);
    base  = flange_t;                         // bottom flange top surface (하단 플랜지 상단 표면)
    teeth_top = base + belt_width;
    top_flange_top = teeth_top + flange_t;
    total_h = top_flange_top + hub_h;

    difference() {
        union() {
            cylinder(d = fd, h = flange_t, $fn = max(64, teeth * 6)); // bottom flange (하단 플랜지)
            translate([0, 0, base]) linear_extrude(belt_width)    // toothed body (톱니 바디)
                gt2_pulley_2d(teeth);
            translate([0, 0, teeth_top])
                cylinder(d = fd, h = flange_t, $fn = max(64, teeth * 6)); // top flange (상단 플랜지)
            if (hub_h > 0)
                translate([0, 0, top_flange_top])
                    union() {
                        cylinder(d = hub_d, h = hub_h, $fn = 72);
                        translate([0, 0, hub_h * 0.62])
                            cylinder(d = hub_d + 0.9, h = hub_h * 0.12, $fn = 72);
                    }
        }
        through(bore + bore_clearance, total_h);
        // 45° bore lead-ins: easier slide onto the shaft + bed-face elephant-foot relief.
        // (보어 45° 리드인: 샤프트에 끼우기 쉬움 + 베드 면 엘리펀트풋 완화.)
        chamfer_dn(bore + bore_clearance, print_chamfer);
        translate([0, 0, total_h]) chamfer_up(bore + bore_clearance, print_chamfer);
        if (set_screw_d > 0) {
            sz = (hub_h > 0) ? top_flange_top + hub_h / 2 : base + belt_width / 2;
            translate([0, 0, sz]) rotate([-90, 0, 0])
                cylinder(d = set_screw_d, h = fd, $fn = 24);
        }
    }
}

module input_pulley()  { gt2_pulley(input_teeth,  input_bore,  input_hub_h);  }
module output_pulley() { gt2_pulley(output_teeth, output_bore, output_hub_h); }
