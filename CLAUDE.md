# CLAUDE.md

This repository contains a parametric OpenSCAD design for a NEMA17 GT2 belt robot joint actuator.
(이 저장소는 NEMA17 GT2 벨트 로봇 관절 액추에이터를 위한 파라메트릭 OpenSCAD 디자인을 포함하고 있습니다.)

## Layout (구조)

- `cad/lib/params.scad` is the single source of truth for dimensions, fits, and render defaults.
  (`cad/lib/params.scad`는 치수, 공차 및 렌더링 기본값에 대한 단일 진실 공급원(single source of truth)입니다.)
- `cad/lib/*.scad` contains reusable modules for GT2 pulleys, plates, printed parts, utilities, and assembly visualization.
  (`cad/lib/*.scad`는 GT2 풀리, 플레이트, 출력 부품, 유틸리티 및 어셈블리 시각화를 위한 재사용 가능한 모듈을 포함합니다.)
- `cad/src/*.scad` contains one printable part per file.
  (`cad/src/*.scad`는 파일당 하나의 출력 가능한 부품을 포함합니다.)
- `cad/src/assembly.scad` is preview-only and should not be exported as a printable STL.
  (`cad/src/assembly.scad`는 미리보기 전용이며 출력 가능한 STL로 내보내서는 안 됩니다.)
- `cad/render.ps1` exports printable parts into `cad/build/`.
  (`cad/render.ps1`은 출력 가능한 부품을 `cad/build/`로 내보냅니다.)

## Commands (명령어)

```powershell
.\cad\render.ps1
.\cad\render.ps1 motor_plate
```

Manual example (수동 실행 예시):

```powershell
& "C:\Program Files\OpenSCAD\openscad.exe" -o cad\build\motor_plate.stl --export-format binstl cad\src\motor_plate.scad
```

## Design Rules (디자인 규칙)

- Keep dimensions in `cad/lib/params.scad`; do not hard-code shared dimensions in part files.
  (치수는 `cad/lib/params.scad`에 유지하세요. 부품 파일에 공유되는 치수를 하드코딩하지 마세요.)
- Keep `cad/src/assembly.scad` preview-only.
  (`cad/src/assembly.scad`는 미리보기 전용으로 유지하세요.)
- The default belt is GT2 6 mm closed-loop 150 mm with `center_distance = 32.5`.
  (기본 벨트는 `center_distance = 32.5`인 GT2 6mm 폐곡선(closed-loop) 150mm입니다.)
- The output shaft uses 608ZZ bearings. Tune `bearing_press_fit` for the actual printer before relying on the fit.
  (출력 샤프트는 608ZZ 베어링을 사용합니다. 조립 공차에 의존하기 전에 실제 프린터에 맞게 `bearing_press_fit`을 조정하세요.)
- The motor plate corner towers are part of the motor plate body conceptually; preserve their alignment with the plate outline and output pulley keepout.
  (모터 플레이트 코너 타워는 개념적으로 모터 플레이트 본체의 일부입니다. 플레이트 외곽선 및 출력 풀리 여유 공간(keepout)과의 정렬을 유지하세요.)
