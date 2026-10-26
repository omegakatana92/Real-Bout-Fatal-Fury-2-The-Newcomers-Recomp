# Real Bout Fatal Fury 2 — Neo Geo Static Recompilation

A native Windows x64 and Linux x86_64 (Steam Deck AppImage) recompilation of
SNK's **Real Bout Fatal Fury 2 - The Newcomers** (MVS, NGH-240), built on
[NeoGeoRecomp](https://github.com/sp00nznet/neogeorecomp) v0.2.0.

The cartridge's Motorola 68000 program is translated ahead of time into C and
runs natively against a model of the MVS board. It is not an emulator
wrapper. Addresses without a recompiled entry point (for example computed
jumps found only at runtime) fall back to the bundled Musashi interpreter,
and `--verify` checks every native block against that interpreter.

No game ROMs or BIOS files are included. You supply your own legally
obtained dump.

## Status

| Item | Measured result |
|---|---|
| ROM set | all 14 game files + 4 BIOS files match MAME `rbff2` / `neogeo` |
| Boot | real MVS BIOS, Neo Geo logo, title, attract, menus, match |
| Recompiled code | 19,323 routines, 34,731 runtime entry points |
| Native coverage | **99.964%** of executed instructions over a 24,000-frame scripted match (422,752,018 native / 153,658 interpreted) |
| `--verify` | **23,457,889 blocks, 0 mismatches** |
| Audio | Z80 driver + YM2610; 6:45 WAV, mean −19.8 dB, non-silent |
| Windows | Release build packaged and launched; headless, windowed and fullscreen runs tested |
| Steam Deck AppImage | built (16.5 MB), headless + windowed + fullscreen tested on Linux x86_64; actual Deck hardware untested |

See [docs/compatibility.md](docs/compatibility.md) for the exact test log and
known limitations. The native/interpreter screenshots match through frame
13,100 of the test match and then diverge at a timing-sensitive AI decision;
`--verify` remains clean. That is documented rather than hidden.

## Requirements

- MAME set **rbff2** (MVS version) unzipped into one directory:
  `240-p1.p1`, `240-p2.sp2`, `240-c1.c1` … `240-c6.c6`, `240-s1.s1`,
  `240-m1.m1`, `240-v1.v1` … `240-v4.v4`.
- Neo Geo system ROMs in the same directory: `sp-s2.sp1` (the default MVS
  Asia/Europe BIOS), `sfix.sfix`, `sm1.sm1`, `000-lo.lo`.
- Windows x64: Visual Studio 2022/2026 with the C++ workload, CMake 3.21+,
  Ninja, and clang-cl (LLVM) on `PATH`. The default build uses clang-cl with
  the MSVC ABI; `-Msvc` selects the Visual Studio/MSVC compiler instead.
- Linux x86_64: `gcc`/`g++`, CMake 3.21+, `libsdl2-dev`, `make`.

All 14 game ROMs and the four required BIOS files are checked by size and
CRC32/SHA1 against MAME's definition; see `docs/rom-layout.md`.

## Fresh clone

The game repo stores the toolkit as a submodule pinned to v0.2.0. The four
generic fixes this port needs are in `patches/`:

```bash
git clone --recurse-submodules https://github.com/omegakatana92/Real-Bout-Fatal-Fury-2-The-Newcomers-Recomp.git
cd Real-Bout-Fatal-Fury-2-The-Newcomers-Recomp
git -C neogeorecomp apply ../patches/0001-generic-runtime-and-fullscreen.patch
```

The prebuilt releases already contain the patched runtime, so this step is
only for building from source. `git -C neogeorecomp apply --reverse` removes
it again. No ROMs, BIOS files, generated C, CMake caches or build
directories are committed.

## Quick start (Windows)

```powershell
# One-time: fetch the official SDL2 VC development package.
powershell -ExecutionPolicy Bypass -File scripts\fetch-deps.ps1

# Configure with clang-cl + Ninja, recompile the 68000 program, build and
# stage dist/windows/RBFF2-Windows-x64/.
powershell -ExecutionPolicy Bypass -File scripts\build-windows.ps1 `
    -RomDir C:\path\to\roms -Test
```

The default build uses `build-windows/`. `-Msvc` switches to the Visual
Studio generator and MSVC compiler; on this 5 MB program MSVC 19.51 can spend
tens of minutes on one generated translation unit, which is why clang-cl is
the default. The output is still a native Windows x64 executable using the
MSVC ABI and runtime.

To run it directly after a manual build:

```powershell
.\build-windows\Release\RBFF2.exe --rom-path C:\path\to\roms
```

## Quick start (Linux / Steam Deck)

```bash
# Native Linux build
cmake -S . -B build-linux -DCMAKE_BUILD_TYPE=Release -DRBFF2_ROM_DIR="$PWD/roms"
cmake --build build-linux --parallel "$(nproc)"
./build-linux/RBFF2 --rom-path "$PWD/roms" --fullscreen

# AppImage
./packaging/appimage/build-appimage.sh "$PWD/roms"
```

The AppImage is written to
`dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage`. It does not contain ROMs;
put a `roms` directory next to the AppImage, or pass `--rom-path DIR`. In
Steam Gaming Mode add the AppImage as a non-Steam game; no launch options
are required.

## Controls

| Action | Keyboard | Controller |
|---|---|---|
| Move | Arrow keys | D-pad or left stick |
| Neo Geo A / B / C / D | Z / X / C / V | A / B / X / Y (Xbox layout) |
| Start (P1 / P2) | 1 / 2 | Start |
| Insert coin (P1 / P2) | 5 / 6 | Back / — |
| Select | 3 | Left shoulder |
| Service | 9 | — |
| Test switch | F2 | — |
| Fullscreen | F11 / Alt+Enter | — |
| Quit | Esc | Steam overlay / close window |

On MVS, insert a coin before Start will do anything. The layout is the
toolkit's fixed SDL GameController mapping; pads SDL recognizes work without
configuration. A pad SDL does not recognize can be described with the
`SDL_GAMECONTROLLERCONFIG` environment variable.

## Command line

The player is the toolkit's standard host, plus a generic `--fullscreen`
option added in this port:

```
  --rom-path DIR        game ROM files (default: roms)
  --bios-path DIR       system ROM files (default: the ROM path)
  --bios FILE           system ROM (default: sp-s2.sp1)
  --headless            no window; run as fast as possible
  --record FILE.mp4     pipe frames to ffmpeg
  --frames N            stop after N frames
  --screenshot N:FILE   save frame N as PNG (repeatable)
  --input FILE          scripted input
  --interp              run everything in the interpreter
  --verify              re-run every recompiled block in the interpreter
  --dump-misses FILE    write interpreted entry points for the recompiler
  --scale N             window scale (default 3)
  --fullscreen          start fullscreen (F11 toggles)
  --wav FILE            write audio to a WAV file
  --mute                mute window audio
```

## Verification

```bash
# Interpreter boot and board-model check
./build-linux/RBFF2 --headless --interp --rom-path roms --frames 3600

# Recompiled build, every block compared with Musashi
./build-linux/RBFF2 --headless --verify --rom-path roms --frames 6000 \
    --input tests/coin_start.txt

# Coverage pass: record runtime-only entry points, rebuild, repeat
cmake --build build-linux --target profile
cmake --build build-linux --parallel
```

`--verify` prints `[verify] N blocks checked, 0 mismatches` and the final
`[exec]` line reports native blocks, interpreted instructions and uncovered
entry points. Native coverage is only claimed after those runs.

## Project layout

```
CMakeLists.txt              player, generator and profile target
src/game.c, game.h          verified ng_game_t ROM layout
src/main.c                  player -> ng_main()
src/recomp_main.c           generator -> ng_recomp_main()
tests/                      deterministic input scripts
packaging/appimage/         AppDir, desktop entry, icon, AppImage script
scripts/                    Windows/Linux build helpers and SDL2 fetch
patches/                    generic toolkit patch against upstream v0.2.0
docs/                       compatibility, ROM layout, testing, toolkit patches
neogeorecomp/               toolkit v0.2.0 submodule plus local fixes
roms/                       your ROMs (ignored, never redistributed)
dist/                       packaged outputs (ignored)
```

## Licensing

Original project code is **PolyForm Noncommercial 1.0.0** (confirmed by the
project owner): see `LICENSE`. Upstream NeoGeoRecomp keeps its MIT license;
Musashi and z80 are MIT, ymfm is BSD-3-Clause, SDL2 is zlib. See
`THIRD_PARTY_NOTICES.md` and `neogeorecomp/LICENSES/`.

PolyForm Noncommercial does **not** grant commercial distribution rights.
No ROMs, BIOS files or ROM-derived generated code are distributed.
Real Bout Fatal Fury 2, Neo Geo, MVS and AES are trademarks of SNK
Corporation; this project is unaffiliated with SNK.
