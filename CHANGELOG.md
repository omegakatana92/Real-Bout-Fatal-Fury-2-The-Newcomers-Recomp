# Changelog

All notable changes to this port. Format: Keep a Changelog.

## [0.1.0] - 2026-10-26

### Added
- Verified `ng_game_t` layout for MAME set `rbff2` (MVS, NGH-240): 5 MB
  P ROM, 48 MB C ROMs, 128 KB S ROM, 256 KB M ROM, 14 MB V ROMs.
- Native Windows x64 player and generator (`RBFF2.exe`), with MSVC-ABI
  clang-cl build support and a Visual Studio/MSVC fallback.
- Linux x86_64 player and Steam Deck AppImage packaging, with a desktop
  entry, original icon and AppRun.
- Deterministic input scripts for boot/coin/start and a ~3-minute match.
- Project licensing: PolyForm Noncommercial 1.0.0 for original code; MIT,
  BSD-3 and zlib notices preserved for upstream components.
- Documentation: ROM layout/hashes, toolkit patches, testing commands and a
  measured compatibility report.

### Fixed (generic toolkit changes)
- Watchdog reset at `$300001` / `$300000-$3BFFFF`: first-boot backup-RAM
  initialisation now resets the board instead of stopping on the game's
  anti-bootleg screen.
- Sprite renderer no longer reads past the decoded C-ROM when the tile
  number rounds up past a non-power-of-two tile count (48 MB carts).
- Bank-window dispatch checks the selected 1 MB bank; non-zero banks run in
  Musashi instead of executing another bank's translated code.
- Odd PCs are left to Musashi as 68000 address errors instead of aliasing
  the even entry below.
- Fullscreen (`--fullscreen`, F11/Alt+Enter), explicit aspect-correct
  pillarboxing and nearest-neighbour texture scaling.
- `[coverage]` reporting, and `NG_TIMING=1` total-cycle diagnostics.

### Verified
- `--verify`: 23,457,889 blocks, 0 mismatches on a 24,000-frame match.
- 99.964% native execution on that run after one profile pass; 0 uncovered
  entry points.
- Toolkit conformance: 59/60 68000 test programs recompiled (reference
  interpreter also 59/60), CTest 1/1.
- Second-game regression: MAME `rbff1` boots and reaches attract gameplay
  with the same patched toolkit.
- Windows: headless, windowed and fullscreen launches; pillarboxing
  confirmed by desktop capture.
- Linux/AppImage: headless, windowed and fullscreen launches under Xvfb
  1280×800; pillar boxes confirmed by X11 capture; `ldd` clean.
- Steam Deck hardware/Gaming Mode: not available, untested.
