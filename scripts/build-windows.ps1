# Build the Windows x64 Release player and stage it for distribution.
#
# The default toolchain is ClangCL (clang-cl) with the MSVC ABI and Windows
# SDK, driven by Ninja.  The generated 68000 translation units are ~7 MB
# each; MSVC 19.5x can spend tens of minutes optimizing one of them, while
# clang-cl compiles the same file in under a minute.  Pass -Msvc to use the
# Visual Studio generator/MSVC toolset instead.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\build-windows.ps1 `
#       -RomDir C:\path\to\roms
#
# Optional:
#   -SdlDir  <dir containing sdl2-config.cmake>  (default: deps\sdl2\...\cmake)
#   -BuildDir <name>                             (default: build-windows)
#   -Parallel <n>                                (default: 6)
#   -Msvc                                        use the MSVC compiler
#   -Test                                        run a headless smoke test
param(
    [Parameter(Mandatory = $true)][string]$RomDir,
    [string]$SdlDir = '',
    [string]$BuildDir = 'build-windows',
    [int]$Parallel = 6,
    [switch]$Msvc,
    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$RomDir = (Resolve-Path $RomDir).Path
$build = Join-Path $root $BuildDir

if (-not $SdlDir) {
    $candidate = Get-ChildItem (Join-Path $root 'deps\sdl2') -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName 'cmake' } |
        Where-Object { Test-Path (Join-Path $_ 'sdl2-config.cmake') } |
        Select-Object -First 1
    if (-not $candidate) {
        throw 'SDL2 not found. Download the official SDL2 VC development package and unpack it under deps\sdl2\, or pass -SdlDir.'
    }
    $SdlDir = $candidate
}

$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs) { throw 'Visual Studio with the C++ workload was not found.' }
$vsVer = & $vswhere -latest -products * -property installationVersion
$major = ([regex]::Match("$vsVer", '^(\d+)')).Groups[1].Value
$gen = if ($major -eq '18') { 'Visual Studio 18 2026' } else { 'Visual Studio 17 2022' }

$clang = Get-Command clang-cl -ErrorAction SilentlyContinue
if (-not $Msvc -and -not $clang) {
    Write-Warning 'clang-cl was not found; falling back to the MSVC toolset.'
    $Msvc = $true
}

if ($Msvc) {
    Write-Host "== configure ($gen, x64, MSVC) ==" -ForegroundColor Cyan
    & cmake -S $root -B $build -G $gen -A x64 `
        -DSDL2_DIR="$SdlDir" "-DCMAKE_PREFIX_PATH=$(Split-Path $SdlDir -Parent)" `
        "-DRBFF2_ROM_DIR=$RomDir"
    if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed' }
    Write-Host "== build Release (parallel $Parallel) ==" -ForegroundColor Cyan
    & cmake --build $build --config Release --parallel $Parallel
} else {
    $vcvars = Join-Path $vs 'VC\Auxiliary\Build\vcvars64.bat'
    Write-Host "== configure (Ninja, clang-cl, x64) ==" -ForegroundColor Cyan
    $cfg = @"
cmake -S "$root" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DSDL2_DIR="$SdlDir" -DCMAKE_PREFIX_PATH="$(Split-Path $SdlDir -Parent)" -DRBFF2_ROM_DIR="$RomDir"
"@
    & cmd.exe /c "`"$vcvars`" >nul && $cfg"
    if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed' }
    Write-Host "== build Release (parallel $Parallel) ==" -ForegroundColor Cyan
    & cmd.exe /c "`"$vcvars`" >nul && cmake --build `"$build`" --parallel $Parallel"
}
if ($LASTEXITCODE -ne 0) { throw 'build failed' }

$exe = @((Join-Path $build 'RBFF2.exe'), (Join-Path $build 'Release\RBFF2.exe')) |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $exe) { throw "RBFF2.exe was not produced under $build" }

if ($Test) {
    Write-Host "== headless smoke test ==" -ForegroundColor Cyan
    $log = Join-Path $build 'smoke.log'
    & cmd.exe /c "`"$exe`" --headless --rom-path `"$RomDir`" --frames 900 > `"$log`" 2>&1"
    $code = $LASTEXITCODE
    Get-Content $log | Write-Host
    if ($code -ne 0) { throw 'headless smoke test failed' }
}

$dist = Join-Path $root 'dist\windows\RBFF2-Windows-x64'
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force $dist, (Join-Path $dist 'LICENSES'), (Join-Path $dist 'roms') | Out-Null

Copy-Item $exe $dist
Copy-Item (Join-Path $root 'packaging\windows\README.txt') $dist
Copy-Item (Join-Path $root 'LICENSE') $dist
Copy-Item (Join-Path $root 'LICENSE-STATUS.md') $dist
Copy-Item (Join-Path $root 'THIRD_PARTY_NOTICES.md') $dist
Copy-Item (Join-Path $root 'neogeorecomp\LICENSE') (Join-Path $dist 'LICENSES\neogeorecomp.txt')
Copy-Item (Join-Path $root 'neogeorecomp\NOTICE') (Join-Path $dist 'LICENSES\neogeorecomp-NOTICE.txt')
Copy-Item (Join-Path $root 'neogeorecomp\LICENSES\*.txt') (Join-Path $dist 'LICENSES')
Copy-Item (Join-Path $root 'packaging\windows\SDL2.txt') (Join-Path $dist 'LICENSES\SDL2.txt')

$sdlDll = Get-ChildItem (Split-Path (Split-Path $SdlDir -Parent) -Parent) -Recurse -Filter SDL2.dll |
    Select-Object -First 1
if (-not $sdlDll) {
    $sdlDll = @((Join-Path $build 'SDL2.dll'), (Join-Path $build 'Release\SDL2.dll')) |
        Where-Object { Test-Path $_ } | ForEach-Object { Get-Item $_ } | Select-Object -First 1
}
if ($sdlDll) { Copy-Item $sdlDll.FullName $dist } else { Write-Warning 'SDL2.dll not found; the player will need it on PATH.' }

# /MD and the C++ parts need the VC runtime when the target has no redist.
foreach ($dll in @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')) {
    $src = Join-Path $env:SystemRoot "System32\$dll"
    if (Test-Path $src) { Copy-Item $src $dist }
}

Copy-Item (Join-Path $root 'docs\rom-layout.md') (Join-Path $dist 'ROM-LAYOUT.md') -ErrorAction SilentlyContinue
Write-Host "wrote $dist" -ForegroundColor Green
