// =============================================================================
//  params.scad  -  Single source of truth for the NEMA17 GT2 joint actuator.
//                  (NEMA17 GT2 조인트 액추에이터의 모든 파라미터를 관리하는 단일 소스)
//  Included by every printable part and by the assembly preview.
//  (모든 출력 가능한 부품과 어셈블리 미리보기에서 인클루드됩니다)
// =============================================================================

/* [ Assembly preview (어셈블리 미리보기) ] */
show_labels = true; // assembly annotation labels (어셈블리 주석 라벨 표시)

/* [ Clearances / fit (공차 / 맞춤 - 0.28mm Standard @ SparkX i7, 0.4 노즐 기준) ] */
boolean_eps       = 0.02;
bore_clearance    = 0.20;
tooth_clearance   = 0.06;
bearing_press_fit = 0.10;  // positive value shrinks the 608ZZ pocket for press-fit (diametral) (양수 값은 억지 끼워맞춤을 위해 608ZZ 포켓을 축소시킴, 직경 기준)
print_chamfer     = 0.6;   // 45° lead-in on bores/shaft: easier press-fit/slip-fit + elephant-foot relief (보어/샤프트 45° 리드인: 압입/슬립핏 용이 + 엘리펀트풋 완화)

/* [ GT2 belt (GT2 벨트) ] */
belt_pitch       = 2.0;
belt_pld         = 0.254;
belt_width       = 6.0;
belt_thickness   = 1.4;

/* [ Pulleys (풀리) ] */
input_teeth      = 20;
output_teeth     = 60;
input_bore       = 5.0;
output_bore      = 8.0;
flange_t         = 1.2;
flange_extra     = 1.9;
input_hub_h      = 5.0;
output_hub_h     = 6.0;
set_screw_d      = 3.2;

/* [ Geometry / center distance (형상 / 중심 거리) ] */
center_distance  = 32.5;   // 150mm GT2 closed-loop belt nominal centre distance (20T -> 60T) (150mm GT2 폐루프 벨트의 공칭 중심 거리, 20T -> 60T)
tension_travel   = 6.0;
plate_gap        = 25.0;

/* [ NEMA17 motor (SF2424 = SANYO DENKI SF2424-12B41) ] */
motor_size       = 42.3;
motor_hole_pitch = 31.0;
motor_screw_d    = 3.4;
motor_boss_d     = 24.0;
motor_body_len   = 59.5;

/* [ Bearings / journal (베어링 / 저널) ] */
bearing_od       = 22.0;
bearing_w        = 7.0;

/* [ Frame plates / integrated corner towers (프레임 플레이트 / 일체형 코너 타워) ] */
plate_th         = bearing_w;
standoff_screw_d = 3.4;
post_pilot_d     = 2.6;
post_pilot_depth = 14.0;
post_tower_size  = 20.0;
post_wall        = bearing_w;  // post leg thickness = plate thickness; one structural thickness everywhere (포스트 레그 두께 = 플레이트 두께; 구조 두께를 어디서나 동일하게)
post_inner_relief_r = post_tower_size - post_wall;  // inner-corner round derived from post_wall; larger round also clears the mount slot + M3 head (post_wall에서 파생된 안쪽 모서리 둥글기; 더 큰 둥글기는 마운트 슬롯 및 M3 헤드 간섭도 방지)
post_pulley_clearance = 2.0;
strut_w          = 8.0;
hub_collar       = 6.0;
boss_extra       = 3.0;
motor_pad_margin = 3.0;
plate_edge_margin = 8.0;
plate_corner_r    = 12.0;

/* [ Visual refinement (시각적 개선) ] */
skin_rounding     = 0.85;

/* [ Bearing pocket (베어링 포켓) ] */
// 608ZZ outer race is held only by the press-fit bore.
// (608ZZ 외륜은 억지 끼워맞춤 보어만으로 고정됩니다.)

/* [ Printed shaft (phase 1) (출력용 샤프트 (1단계)) ] */
shaft_overhang   = 30.0;
shaft_flat_depth = 1.0;

/* [ Output shaft retention (출력 샤프트 고정) ] */
// Integral shoulder seats on the upper bearing GAP-side (inner) race face ->
// positive PULL-OUT stop (shaft can't slide out toward the arm). Push-in toward
// the motor is held by the output-pulley set screw on the D-cut. The output
// pulley installs HUB-DOWN so its hub clears this inboard shoulder.
// (일체형 숄더가 상단 베어링 갭쪽(안쪽) 내륜 면에 안착됨 -> pull-out(빠짐) 기계적 정지(샤프트가 암 쪽으로 빠지지 않음). 모터 쪽으로 밀려 들어가는 것은 D-컷의 출력 풀리 무두볼트가 고정. 출력 풀리는 허브가 아래로 가게 조립하여 이 안쪽 숄더를 피함.)
shaft_shoulder_d = 12.0;
shaft_shoulder_h = 3.0;

/* [ Output arm (optional joint link) (출력 암 (선택적 조인트 링크)) ] */
arm_len          = 40.0;
arm_th           = 6.0;
arm_hub_d        = 18.0;
arm_end_hole_d   = 4.0;

/* [ Quality (품질) ] */
$fa = 2;
$fs = 0.4;

// Standoff / corner tower screw positions in the plate plane.
// (플레이트 평면 상의 스탠드오프 / 코너 타워 나사 위치)
// Both ends share the same |Y| so the four pilots form a symmetric rectangle.
// (양 끝이 동일한 |Y| 값을 공유하므로 4개의 파일럿 홀이 대칭형 직사각형을 형성함)
post_y = motor_size/2;   // ±21.15 — push posts out to the plate corners (±21.15 — 포스트를 플레이트 모서리 쪽으로 밀어냄)
standoffs = [
    [-motor_size/2 - 3, -post_y],
    [-motor_size/2 - 3,  post_y],
    [ center_distance + 25, -post_y],
    [ center_distance + 25,  post_y]
];
