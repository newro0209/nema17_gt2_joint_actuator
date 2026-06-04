# render.ps1 - export printable OpenSCAD parts to cad/build/*.stl
# (출력 가능한 OpenSCAD 부품들을 cad/build/*.stl 파일로 내보냅니다)
# Usage:  .\cad\render.ps1                  (all printable parts / 모든 출력 가능한 부품)
#         .\cad\render.ps1 motor_plate      (single part / 단일 부품)
# assembly.scad is preview-only and is never exported.
# (assembly.scad는 미리보기 전용이므로 내보내지 않습니다.)
param([string]$Part = "*")

$scad = "C:\Program Files\OpenSCAD\openscad.com"
if (-not (Test-Path $scad)) {
    $cmd = Get-Command openscad.com -ErrorAction SilentlyContinue
    if ($cmd) { $scad = $cmd.Source } else {
        $scad = "C:\Program Files\OpenSCAD\openscad.exe"
        if (-not (Test-Path $scad)) { throw "OpenSCAD not found" }
    }
}

$srcDir   = Join-Path $PSScriptRoot 'src'
$buildDir = Join-Path $PSScriptRoot 'build'
New-Item -ItemType Directory -Force $buildDir | Out-Null

if ($Part -eq "*") {
    Get-ChildItem -Path $buildDir -Filter "*.stl" -File | Remove-Item -Force
}

$parts = @(Get-ChildItem (Join-Path $srcDir "$Part.scad") -ErrorAction SilentlyContinue |
    Where-Object { $_.BaseName -ne "assembly" })

if ($parts.Count -eq 0) {
    $available = (Get-ChildItem (Join-Path $srcDir "*.scad") |
        Where-Object { $_.BaseName -ne "assembly" } |
        ForEach-Object { $_.BaseName }) -join ", "
    throw "No printable part matches '$Part'. Available parts: $available"
}

$parts | ForEach-Object {
    $out = Join-Path $buildDir "$($_.BaseName).stl"
    Write-Host "Rendering $($_.Name) -> $out"
    & $scad -o $out --export-format binstl $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "OpenSCAD failed for $($_.Name)" }
}
