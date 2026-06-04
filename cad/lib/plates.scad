// =============================================================================
//  plates.scad  -  Frame plates + output bearing feature.
//                  (프레임 플레이트 + 출력 베어링 기능)
//  Filament-optimised truss of nodes (bearing hub, post bosses, motor pad)
//  joined by struts. The two plates are intentionally DIFFERENT:
//  (스트럿으로 연결된 노드(베어링 허브, 포스트 보스, 모터 패드)들로 이루어진 필라멘트 최적화 트러스 구조입니다. 두 플레이트는 의도적으로 다르게 설계되었습니다:)
//    * motor plate (base) : solid NEMA17 pad + integral posts + arms to the
//                           bearing hub. Carries motor + belt load.
//      (모터 플레이트 (하단): 솔리드 NEMA17 패드 + 일체형 포스트 + 베어링 허브로 이어지는 암. 모터 및 벨트 하중을 견딥니다.)
//    * support plate (lid): continuous upper bearing support.
//      (서포트 플레이트 (상단): 끊김 없이 이어지는 상단 베어링 지지부.)
//
//  Bearing pocket: plate_th matches bearing_w, so there is no local bearing-hub
//  protrusion; the plain press-fit bore spans the full plate thickness.
//  (베어링 포켓: plate_th를 bearing_w에 맞춰 국부적인 베어링 허브 돌출 없이 단순 억지 끼워맞춤 보어가 플레이트 전체 두께를 관통합니다.)
//  Depends on plate/bearing/motor params + standoffs and through()/xslot().
//  (플레이트/베어링/모터 파라미터 + 스탠드오프 및 through()/xslot()에 의존합니다.)
// =============================================================================

// Pocket height needed to host the full bearing width.
// (베어링 전체 너비를 수용하기 위해 필요한 포켓 높이)
function bearing_hub_h() = bearing_w;

// 2D rounded/tapered bar between two points.
// (두 지점 사이의 둥근/테이퍼드 2D 바)
module strut2d(a, b, w = strut_w, wa = 0, wb = 0) {
    da = (wa == 0) ? w : wa;
    db = (wb == 0) ? w : wb;
    hull() {
        translate(a) circle(d = da, $fn = 32);
        translate(b) circle(d = db, $fn = 32);
    }
}

module hub2d(extra = 0) { translate([center_distance, 0]) circle(d = bearing_od + 2 * hub_collar + extra, $fn = 96); }
module post_boss2d(p, extra = 0) { translate(p) circle(d = standoff_screw_d + 2 * boss_extra + extra, $fn = 48); }
module motor_pad2d(extra = 0) {
    offset(r = motor_pad_margin + extra, $fn = 32)
        square([motor_size, motor_size], center = true);
}

function plate_min_x() = min(-motor_size / 2, standoffs[0][0], standoffs[1][0]) - plate_edge_margin;
function plate_max_x() = max(center_distance + bearing_od / 2, standoffs[2][0], standoffs[3][0]) + plate_edge_margin;
function plate_min_y() = min(-motor_size / 2, standoffs[0][1], standoffs[2][1]) - plate_edge_margin;
function plate_max_y() = max( motor_size / 2, standoffs[1][1], standoffs[3][1]) + plate_edge_margin;

module plate_shell2d() {
    min_x = plate_min_x();
    max_x = plate_max_x();
    min_y = plate_min_y();
    max_y = plate_max_y();
    translate([(min_x + max_x) / 2, (min_y + max_y) / 2])
        rounded_rect2d([max_x - min_x, max_y - min_y], plate_corner_r);
}

module plate_window2d(is_base) {
    if (is_base) {
        // Small inspection slots only; keep motor mount, bearing hub, and post bosses tied together.
        // (작은 검사용 슬롯만 생성; 모터 마운트, 베어링 허브, 포스트 보스들이 서로 연결된 상태를 유지함.)
        translate([center_distance * 0.42, -motor_size / 2 + 8])
            rounded_rect2d([center_distance * 0.48, 5.0], 2.5);
        translate([center_distance * 0.42,  motor_size / 2 - 8])
            rounded_rect2d([center_distance * 0.48, 5.0], 2.5);
    } else {
        // No lid window: keep the support plate as a continuous bearing support.
        // (상단 윈도우 없음: 서포트 플레이트를 연속적인 베어링 지지부로 유지함.)
    }
}

// Support-plate (lid) footprint: reduced 4-spoke spider (no perimeter ties).
// (서포트 플레이트 (상단) 풋프린트: 테두리 연결부가 없는 축소된 4스포크 스파이더 형태.)
module lid_outline() {
    soft_outline2d()
        union() {
            plate_shell2d();
            hub2d(2.0);
            for (p = standoffs) post_boss2d(p, 1.6);
        }
}

// Motor-plate (base) footprint: solid mounting pad + truss out to hub/posts.
// (모터 플레이트 (하단) 풋프린트: 솔리드 마운팅 패드 + 허브/포스트로 뻗어나가는 트러스 형태.)
module base_outline() {
    soft_outline2d()
        union() {
            plate_shell2d();
            motor_pad2d(1.0);
            hub2d(2.0);
            for (p = standoffs) post_boss2d(p, 1.8);
        }
}

// Local bearing-hub boss beyond the plate body, only needed if plate_th < bearing_w.
// (plate_th가 bearing_w보다 작을 때만 필요한 플레이트 바디 밖 국부 베어링 허브 보스.)
module bearing_hub_boss(is_base) {
    extra = bearing_hub_h() - plate_th;
    if (extra > 0)
        translate([center_distance, 0, is_base ? plate_th : -extra])
            cylinder(d = bearing_od + 2 * hub_collar + 1.0, h = extra, $fn = 96);
}

// Bearing pocket: press-fit bore only.
// (베어링 포켓: 억지 끼워맞춤 보어만.)
module output_bore_feature(is_base) {
    H = bearing_hub_h();
    pf = bearing_od - bearing_press_fit;
    z0 = is_base ? 0 : plate_th - H;
    translate([center_distance, 0, 0]) {
        translate([0, 0, z0])
            cylinder(d = pf, h = H + boolean_eps, $fn = 80);
        // 45° lead-in at both outer faces: self-centering press-fit start + elephant-foot relief.
        // (양쪽 외부 면 45° 리드인: 압입 자동 정렬 + 엘리펀트풋 완화.)
        translate([0, 0, plate_th]) chamfer_up(pf, print_chamfer, 80);
        chamfer_dn(pf, print_chamfer, 80);
    }
}

// is_base : true  -> motor plate (pad + integral posts + self-tap pilots + motor cuts)
//           (true  -> 모터 플레이트 (패드 + 일체형 포스트 + 셀프태핑 파일럿 + 모터 마운트 컷))
//           false -> support lid (reduced spider + M3 clearance through-holes)
//           (false -> 서포트 상단 (축소된 스파이더 + M3 클리어런스 관통 홀))
module frame_body(is_base) {
    difference() {
        union() {
            linear_extrude(plate_th)
                if (is_base) base_outline(); else lid_outline();
            bearing_hub_boss(is_base);
        }

        output_bore_feature(is_base);

        if (is_base) {
            // NEMA17 boss + 4 slotted M3 mount holes through the plate
            // (NEMA17 보스 + 플레이트를 관통하는 4개의 M3 마운트용 슬롯)
            motor_mount_cuts(-boolean_eps, plate_th + 2 * boolean_eps);
        } else {
            // lid: screws pass straight through into the posts below
            // (상단: 나사가 일직선으로 아래쪽 포스트까지 관통함)
            for (p = standoffs)
                translate([p[0], p[1], 0]) through(standoff_screw_d, plate_th, 24);
        }
    }
}

// NEMA17 boss clearance + 4 tension-slotted M3 mount holes, extruded over z0..z0+h.
// (NEMA17 보스 클리어런스 + 4개의 장력 조절용 M3 마운트 슬롯을 z0부터 z0+h까지 돌출.)
// Shared by the plate body AND the corner towers so the motor-end towers do not
// cover the mount slots (they get a slot-shaped channel for screw access + travel).
// (플레이트 바디 및 코너 타워에서 공유하여 모터 쪽 타워가 마운트 슬롯을 가리지 않게 함 (나사 접근 및 이동을 위한 슬롯 형태의 채널을 확보함).)
module motor_mount_cuts(z0, h) {
    translate([0, 0, z0]) linear_extrude(h)
        xslot(motor_boss_d, tension_travel);
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * motor_hole_pitch / 2, sy * motor_hole_pitch / 2, z0])
            linear_extrude(h)
                xslot(motor_screw_d, tension_travel);
}

module post_tower2d(p) {
    sx = (p[0] < center_distance) ? -1 : 1;
    sy = (p[1] < 0) ? -1 : 1;
    x0 = (sx < 0) ? plate_min_x() : plate_max_x() - post_tower_size;
    y0 = (sy < 0) ? plate_min_y() : plate_max_y() - post_tower_size;
    // round the inner corner back so each tower clears the adjacent feature
    // (mount slot + M3 head + travel on the motor end, pulley keepout on the
    // output end) while keeping the outer pilot boss.
    // (각 타워가 인접한 형태(모터 쪽의 마운트 슬롯+M3 헤드+이동 공간, 출력 쪽의 풀리 간섭 구역)와 간섭되지 않도록 안쪽 모서리를 둥글게 깎아냄. 외곽 파일럿 보스는 유지함.)
    icx = (sx < 0) ? x0 + post_tower_size : x0;  // inner corner X (toward plate centre) (안쪽 모서리 X 좌표 - 플레이트 중심 방향)
    icy = (sy < 0) ? y0 + post_tower_size : y0;  // inner corner Y (toward plate centre) (안쪽 모서리 Y 좌표 - 플레이트 중심 방향)
    difference() {
        intersection() {
            plate_shell2d();
            translate([x0, y0]) square([post_tower_size, post_tower_size]);
        }
        translate([icx, icy]) circle(r = post_inner_relief_r, $fn = 64);
    }
}

module post_towers() {
    for (p = standoffs)
        translate([0, 0, plate_th - boolean_eps])
            linear_extrude(plate_gap + boolean_eps)
                post_tower2d(p);
}

module motor_post_frame() {
    difference() {
        post_towers();
        translate([center_distance, 0, plate_th - boolean_eps])
            cylinder(d = pulley_od(output_teeth) + 2 * flange_extra + 2 * post_pulley_clearance,
                     h = plate_gap + 2 * boolean_eps, $fn = 96);
    }
}

module motor_posts() {
    difference() {
        motor_post_frame();
        // self-tap pilot bored down from each post top
        // (각 포스트 상단에서 파내려간 셀프태핑 파일럿 홀)
        for (p = standoffs)
            translate([p[0], p[1], plate_th + plate_gap - post_pilot_depth])
                cylinder(d = post_pilot_d, h = post_pilot_depth + boolean_eps, $fn = 24);
    }
}

module motor_plate_body() { frame_body(true); }
module motor_plate()      { union() { motor_plate_body(); motor_posts(); } }   // base + integral posts (하단 + 일체형 포스트)
module support_plate()    { frame_body(false); }
