# render.ps1 - export printable OpenSCAD parts to cad/build/*.stl
# Usage:  .\cad\render.ps1                  (all printable parts)
#         .\cad\render.ps1 motor_plate      (single part)
# assembly.scad is preview-only and is never exported.
param([string]$Part = "*")

$scad = "C:\Program Files\OpenSCAD\openscad.exe"
if (-not (Test-Path $scad)) {
    $cmd = Get-Command openscad.com -ErrorAction SilentlyContinue
    if ($cmd) { $scad = $cmd.Source } else { throw "OpenSCAD not found" }
}

$srcDir   = Join-Path $PSScriptRoot 'src'
$buildDir = Join-Path $PSScriptRoot 'build'
New-Item -ItemType Directory -Force $buildDir | Out-Null

Get-ChildItem (Join-Path $srcDir "$Part.scad") |
    Where-Object { $_.BaseName -ne "assembly" } |
    ForEach-Object {
        $out = Join-Path $buildDir "$($_.BaseName).stl"
        Write-Host "Rendering $($_.Name) -> $out"
        & $scad -o $out --export-format binstl $_.FullName
        if ($LASTEXITCODE -ne 0) { throw "OpenSCAD failed for $($_.Name)" }
    }
