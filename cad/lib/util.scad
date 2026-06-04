// =============================================================================
//  util.scad  -  Small generic primitives reused across parts (DRY helpers).
//                (여러 부품에서 재사용되는 작은 공통 기본 도형 (DRY 도우미))
//  Not standalone; included after params.scad by each part entry point.
//  (단독 실행 불가; 각 부품 진입점의 params.scad 이후에 인클루드됨)
// =============================================================================

// Through-cut cylinder for clean difference(): bored from boolean_eps below z=0
// up past z=h. Wrap in translate([x, y, 0]) to position in the XY plane.
// Overlap is just boolean_eps so booleans stay tight (no oversized cuts).
// (깔끔한 difference() 처리를 위한 관통형 실린더: z=0 아래 boolean_eps부터 z=h 위까지 파냅니다.
// XY 평면에 배치하려면 translate([x, y, 0])로 감싸세요.
// 겹치는 부분은 boolean_eps만큼이므로 부울 연산이 정밀하게 유지됩니다 (과도한 컷팅 없음).)
module through(d, h, fn = 60) {
    translate([0, 0, -boolean_eps]) cylinder(d = d, h = h + 2 * boolean_eps, $fn = fn);
}

// Hollow cylinder (outer/inner diameter, base at z=0).
// (중공 실린더 (외경/내경, 밑면은 z=0))
module ring3d(od, id, h) {
    difference() {
        cylinder(d = od, h = h, $fn = 80);
        through(id, h);
    }
}

module soft_outline2d(r = skin_rounding) {
    offset(r = r, $fn = 24) offset(delta = -r) children();
}

module rounded_rect2d(size, r) {
    x = size[0];
    y = size[1];
    rr = min(r, min(x, y) / 2);
    hull() {
        translate([-x / 2 + rr, -y / 2 + rr]) circle(r = rr, $fn = 48);
        translate([ x / 2 - rr, -y / 2 + rr]) circle(r = rr, $fn = 48);
        translate([-x / 2 + rr,  y / 2 - rr]) circle(r = rr, $fn = 48);
        translate([ x / 2 - rr,  y / 2 - rr]) circle(r = rr, $fn = 48);
    }
}

// 2D stadium slot along X (used for the motor tensioning slots).
// (X축 방향 2D 스타디움 슬롯 (모터 장력 조절 슬롯에 사용됨))
module xslot(d, len) {
    hull() {
        translate([-len / 2, 0]) circle(d = d, $fn = 32);
        translate([ len / 2, 0]) circle(d = d, $fn = 32);
    }
}
