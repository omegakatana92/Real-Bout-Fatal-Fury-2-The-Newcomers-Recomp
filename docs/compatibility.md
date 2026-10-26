# Compatibility and verification report

Game: **Real Bout Fatal Fury 2 - The Newcomers** (MVS), MAME set `rbff2`,
NGH-240.

Toolkit: NeoGeoRecomp v0.2.0, commit
`af96b2b4b39b42b392b17bcaa6a74a5f27088202`, plus the generic fixes in
`docs/toolkit-patches.md`.

Every result below comes from an actual run in this workspace. Anything not
run is marked **untested**, not assumed.

## Hardware profile

| Area | Result |
|---|---|
| 68000 program | 5 MB P ROM, 1 MB fixed + 4 MB standard-banked |
| Encryption / protection | none (normal PROGBK1 MVS cart) |
| C ROMs | 48 MB, three odd/even pairs, no CMC42 decryption |
| S ROM | 128 KB, plain fixed layer |
| M ROM | 256 KB Z80 sound driver |
| V ROMs | 14 MB ADPCM-A/B |
| BIOS | real `sp-s2.sp1` MVS Asia/Europe v2, no BIOS HLE |
| Banking | standard `$2FFFF0` 1 MB window; recompiler covers bank 0 |

## ROM validation — passed

All 14 game files match MAME `rbff2` (MVS) by size, CRC32 and SHA1. The four
required BIOS files match the MAME `neogeo` set. Table in
`docs/rom-layout.md`. **Verified.**

## Boot and hardware

| Test | Environment / run | Result |
|---|---|---|
| Interpreter boot, 3,600 frames | Windows x64, headless | **Passed**; BIOS warning/logo, Neo Geo logo, attract demonstration |
| First-boot backup-RAM initialisation + watchdog reset | Windows x64 interpreter | **Passed** after the generic watchdog implementation; no anti-bootleg hang |
| Native boot, 3,600 frames | Windows x64, headless | **Passed**; 2,639,372 blocks, 31,295 interpreted instructions, 47 uncovered entries (before profile) |
| Sprites / fix layer / palettes / raster | screenshots at frames 600, 3,599 | **Correct**; native and interpreter PNGs byte-identical (SHA-256 match) |
| Audio, Z80 + YM2610 | 24,000-frame scripted run, `--wav` | **Passed**; 6:45.50, 55,555 Hz stereo, mean −19.8 dB, max 0.0 dB |
| Watchdog reset during boot | native and interpreter | **Passed**; the game continues instead of showing the anti-bootleg screen |

## Recompilation and correctness

| Metric | Result |
|---|---|
| Recompiler output | 19,323 routines, 35,280 dispatch entries |
| Runtime entry points | 34,731 |
| Test script | `tests/play_long.txt`, 24,000 frames (coin, start, menus, ~3 min match) |
| `--verify` | **23,457,889 blocks checked, 0 mismatches** |
| Native instructions | 422,752,018 |
| Interpreted instructions | 153,658 |
| Native coverage | **99.964%** of executed instructions |
| Uncovered entry points | **0** after one profile pass with the bank-aware runtime |

The remaining 0.036% is code executed from banked P-ROM windows other than
bank 0. The recompiler analyses the first banked megabyte; the runtime
interprets other banks rather than running a translation of the wrong bank.
This is correct but prevents a nominal 100%. See the timing note below.

### Toolkit regression

The modified toolkit's own conformance harness (`build-toolkit-tests`,
CTest) passes **1/1** and the verbose harness reports **59/60** 68000 test
programs recompiled, with the reference Musashi interpreter also at 59/60
(the known `move` / 68020-addressing case). This was run after the watchdog,
bank-dispatch and coverage changes.

As a second-game regression, the same patched toolkit was built against the
unmodified MAME `rbff1` set in a throwaway project: it boots through the
BIOS, shows the character intro and reaches attract-mode gameplay at frame
3,599. This exercises the watchdog and video changes with a different cart;
it is not part of this deliverable.

## Gameplay

| Item | Result |
|---|---|
| BIOS warning / logo | Yes |
| Attract demonstration | Yes (e.g. frame ~3,600) |
| Title screen | Yes (frame ~8,400) |
| Coin insertion | Yes |
| Start / HOW TO PLAY pages | Yes |
| PLAYER SELECT | Yes |
| Match start and controls | Yes; movement, A/B/C/D, hit detection, health bars, round timer |
| Match end / continue / next match | Observed in the 24,000-frame run |
| Two-player / second pad | **Untested** (single-player scripted runs) |
| Test/service menu | **Untested** |

Screenshots were captured locally from the native framebuffer during these
tests (title at frame 8,400, player select at 10,400, match at 16,000).
They are not part of the source or binary distribution because they contain
SNK artwork.

## Timing note (native vs interpreter)

`--verify` proves instruction-level equivalence: 23,457,889 native blocks
matched Musashi exactly. It does not require identical cycle boundaries.

Native and interpreter screenshots are byte-identical at frames 600,
3,599, 9,000, 9,600, 10,400, 11,200, 12,000, 13,000 and 13,100. They first
diverge at frame **13,150**, at a timing-sensitive AI/animation decision in
the match. A diagnostic run at that frame reported 2,666,171,184 simulated
68000 clocks natively and 2,666,171,138 in the interpreter, a difference of
46 clocks (0.0000017%). This is cycle-boundary sensitivity in the game
logic, not a mismatched translated instruction. It is recorded as a known
limitation; this title is not claimed to be frame-identical between the two
execution modes for an entire match.

## Windows deliverable

| Item | Result |
|---|---|
| Toolchain | clang-cl 22.1.7 (MSVC ABI, Windows SDK), Ninja; MSVC 19.51 hangs on one 7 MB generated TU |
| Build | Release x64, **built** |
| Headless packaged run | **Tested**, exit 0, 600/900 frames, 100.000% native for that smoke test |
| Windowed run | **Tested**, exit 0, 600 frames, SDL2 window/audio initialized |
| Fullscreen run (`--fullscreen`) | **Tested**, exit 0, 600 frames |
| Aspect ratio | Captured 1600×900 desktop with the 4:3-ish picture centered and black pillarboxes; not stretched |
| F11 / Alt+Enter toggle | Implemented; the automated key-injection capture was inconclusive in this non-interactive session, so it is **not claimed as visually verified** |
| Controller | SDL GameController mapping present; **physical pad untested** |
| Dist folder | `dist/windows/RBFF2-Windows-x64/` (48.4 MB including SDL2 and VC runtime) |

## Steam Deck AppImage

| Item | Result |
|---|---|
| Build host | Ubuntu 22.04 x86_64 (WSL2), GCC 11.4, CMake 4.4, SDL2 2.0.20 |
| Output | `dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage`, 16,456,184 bytes, executable |
| Headless 24,000-frame run | **Passed**; 34,731 entry points, 422,752,018 native / 153,658 interpreted, 99.964% native |
| `--verify` on the AppImage | **23,457,817 blocks, 0 mismatches** |
| Windowed launch (1280×800 Xvfb) | **Passed**, exit 0, screenshot written |
| Fullscreen launch (1280×800 Xvfb) | **Passed**, exit 0, screenshot written |
| Aspect at 1280×800 | X11 screen capture shows the game centred at 1154×800 with black pillarboxes; not stretched |
| `ldd` | no missing libraries; no glibc/libstdc++ bundled; bundled `libSDL2-2.0.so.0` |
| ROMs inside AppImage | none |
| Steam Deck hardware | **Not available**; Gaming Mode, Steam Input and OLED/LCD hardware are **untested** |
| F11 on Linux | implemented; not visually verified by automated key injection |

The AppImage bundles the build host's SDL2 2.0.20. SteamOS ships a newer SDL2,
but the bundled copy is self-contained. The AppImage was built against glibc
2.35 (Ubuntu 22.04); SteamOS 3 is newer, so the ABI requirement is met.
Steam Deck support is therefore **built and Linux-tested, not
hardware-validated**.

## Known limitations

- Banked code outside bank 0 runs in Musashi. Native coverage is 99.964% for
  the tested match.
- Native and interpreter runs can diverge at a timing-sensitive decision
  after ~13,100 frames (see above); `--verify` remains 0 mismatches.
- The toolkit's controller layout is fixed; remapping is not implemented.
- PolyForm Noncommercial 1.0.0 does not permit commercial distribution.
- No ROMs or BIOS files are bundled.
- A legally obtained `neogeo` system set is required.
- F11 was not visually confirmed by automated input injection.

## Deliverables

| Path | Size | SHA-256 |
|---|---:|---|
| `dist/windows/RBFF2-Windows-x64/` | 48,450,378 bytes | (folder) |
| `dist/windows/RBFF2-Windows-x64.zip` | 17,042,436 bytes | `8236d1597e05648d1592dafaaf5ada7bd6bb46240c700f5e2d4b2a420c67edaa` |
| `dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage` | 16,456,184 bytes | `cb42cc92c4719f14ffc52ad0f133318e455de2d0a6e8fcc2d640a22c84385064` |

The folder sizes/hashes are for the build produced in this workspace. Rebuilds
with different compiler versions will differ; the source and disabled
generated-code rule are what make the results reproducible.

## Test log index

| Log / artifact | Meaning |
|---|---|
| `final-verify.log` | 24,000-frame `--verify` run, 0 mismatches |
| `final-coverage.log` | 24,000-frame coverage run |
| `playlong.wav` | 24,000-frame audio capture (not committed) |
| `build-windows-clang/build.log` | Windows Release build |
| `package-windows.log` | Windows staging and smoke test |
| `dist/windows/RBFF2-Windows-x64/` | staged Windows package |
