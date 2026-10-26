# Fetch the SDL2 VC development package used by the Windows build.
#
# Usage: powershell -ExecutionPolicy Bypass -File scripts\fetch-deps.ps1
param(
    [string]$Version = '2.32.10'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$deps = Join-Path $root 'deps'
$zip = Join-Path $deps "SDL2-devel-$Version-VC.zip"
$out = Join-Path $deps 'sdl2'
$url = "https://github.com/libsdl-org/SDL/releases/download/release-$Version/SDL2-devel-$Version-VC.zip"
$sha256 = 'AF347939395A58B365846AAEA27391E69F9EC9D4DD650D6AC40802159B418A6E'

New-Item -ItemType Directory -Force $deps | Out-Null
if (-not (Test-Path $zip)) {
    Write-Host "downloading SDL2 $Version..."
    Invoke-WebRequest -Uri $url -OutFile $zip
}
$got = (Get-FileHash $zip -Algorithm SHA256).Hash
if ($got -ne $sha256) { throw "SDL2 zip SHA-256 mismatch: $got" }
if (-not (Test-Path (Join-Path $out "SDL2-$Version"))) {
    Expand-Archive -Force $zip $out
}
$cmake = Get-ChildItem $out -Recurse -Filter sdl2-config.cmake |
    Select-Object -First 1
if (-not $cmake) { throw 'SDL2 cmake config not found after extraction' }
Write-Host "SDL2 ready: $($cmake.DirectoryName)" -ForegroundColor Green
