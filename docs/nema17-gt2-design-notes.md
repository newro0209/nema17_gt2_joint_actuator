# NEMA17 GT2 Joint Actuator Design Notes
(NEMA17 GT2 조인트 액추에이터 설계 노트)

## Current Defaults
(현재 기본 설정)

- Reduction: 3:1 using 20T input and 60T output GT2 pulleys.
  (감속비: 20T 입력 및 60T 출력 GT2 풀리를 사용한 3:1 감속.)
- Belt: GT2, 6 mm wide, 150 mm closed loop.
  (벨트: GT2, 폭 6mm, 150mm 폐루프.)
- Bearings: two 608ZZ bearings, 22 OD x 8 ID x 7 W.
  (베어링: 608ZZ 베어링 2개, 외경(OD) 22 x 내경(ID) 8 x 폭(W) 7.)
- Output shaft: 8 mm nominal.
  (출력 축: 공칭 8mm.)

## Fit Notes
(조립 공차 노트)

- `bearing_press_fit` is diametral interference. A positive value makes the pocket smaller.
  (`bearing_press_fit`은 직경의 억지 끼워맞춤 정도를 나타냅니다. 양수 값은 포켓을 더 작게 만듭니다.)
- Bearing retention is press-fit only; there is no outer lip, blind cap, or inner-race relief feature.
  (베어링 고정은 억지 끼워맞춤만 사용합니다. 외부 립, 막힌 캡, 내륜 도피 홈은 없습니다.)
- Test bearing pockets before printing the full frame if the printer/material has not been characterized.
  (프린터나 재료의 특성이 완전히 파악되지 않았다면, 전체 프레임을 출력하기 전에 베어링 포켓을 먼저 테스트하세요.)
