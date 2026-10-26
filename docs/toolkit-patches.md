# Local changes to NeoGeoRecomp v0.2.0

The vendored toolkit is pinned to upstream commit
`af96b2b4b39b42b392b17bcaa6a74a5f27088202` (v0.2.0). This port changes only
generic board/runtime behavior and the window host. There are no
title-specific addresses or patches.

A recreated patch for a clean v0.2.0 checkout is in
`patches/0001-generic-runtime-and-fullscreen.patch`. To reproduce it:

```bash
git clone --recurse-submodules https://github.com/sp00nznet/neogeorecomp
cd neogeorecomp
git checkout af96b2b4b39b42b392b17bcaa6a74a5f27088202
git apply /path/to/patches/0001-generic-runtime-and-fullscreen.patch
```

## 1. Watchdog reset (`src/bus.c`, `src/io.c`, `src/neogeo.c`, `include/neogeorecomp/bus.h`)

The v0.2.0 runtime decoded the watchdog ports as open bus: writes to
`$300001` did nothing. Real MVS hardware resets the board when the watchdog
is not stroked for 3,244,030 master clocks (1,622,015 68000 clocks).

This matters for normal first boot, not just for copy protection. Games with
battery-backed settings (RBFF2 among them) clear the backup RAM and then
idle in a delay loop without stroking the watchdog; they expect the reset to
restart the board with initialized RAM. With the old runtime they fell
through to the game's anti-bootleg warning screen and stopped there.

The implementation is generic:

- any write with address bit 0 set in `$300000-$3BFFFF` strokes the watchdog;
- the frame scheduler polls the deadline and performs a board reset at the
  next scanline, preserving work RAM and backup RAM;
- the reset re-runs the BIOS and the 68000 reset vector without resetting
  the global audio/video timeline.

This does not emulate a game-specific protection trick.

## 2. Sprite tile bounds (`src/video.c`)

A 48 MB C ROM has 393,216 tiles. The LSPC tile number is masked to the next
power of two (524,288), as the unconnected address lines are on hardware.
The old renderer used the mask as an array index without checking it against
the decoded data, so an out-of-range sprite read 32 MB past the allocation
and crashed.

The renderer now skips tile numbers at or above the fitted tile count. This
is a generic safety fix for any cart whose sprite data is not a power of two
in size (48 MB and 96 MB carts).

## 3. Fullscreen host option (`src/neogeo.c`, `src/platform.c`, `src/window_sdl.c`, `src/ng_internal.h`)

Added `--fullscreen` and an F11 (or Alt+Enter) toggle. It uses
`SDL_WINDOW_FULLSCREEN_DESKTOP` and computes an explicit centred destination
rectangle with a uniform 320×224 scale, so the picture is pillarboxed on a
16:10 Steam Deck screen rather than stretched. The texture uses nearest
scaling for crisp pixels. This is a generic window feature and is
independent of the game.

## 4. Bank-window dispatch (`src/exec.c`, `src/bus.c`, `include/neogeorecomp/bus.h`)

The recompiler analyses the fixed bank and the **first megabyte** of the
banked area (`prom + 0x100000`, mapped at `$200000`).  On a multi-bank cart
the same virtual address in the window can hold different code depending on
the bank register.  v0.2.0 dispatched a native entry for the window without
checking the selected bank, so after a bank switch it could execute the
wrong bank's translated code.  RBFF2 has four 1 MB banks and reliably
exposed this once runtime-discovered entry points were added.

`lookup()` now returns the interpreter whenever the window address is
outside bank 0.  `--dump-misses` likewise ignores addresses recorded while
another bank is selected, because the recompiler cannot attach them to a
specific bank.  Native code in the fixed bank and bank 0 is unaffected;
other banks run correctly in Musashi.  This is a general correctness fix for
any multi-bank cart, not a title-specific rule.

The same change stops an odd PC from aliasing the even address below it;
an odd PC is a 68000 address error, which Musashi now raises.

## 5. Coverage and timing reporting (`src/exec.c`, `src/neogeo.c`)

`exec_report()` now prints a second line:

```
[coverage] native instructions 422752018, interpreted 153658, 99.964% native
```

`ng_icount` is the count of instructions executed by generated code;
`exec_interp_instrs` is the interpreter count. `NG_TIMING=1` also prints the
total simulated 68000 clocks, which is how the native/interpreter timing
drift in `docs/compatibility.md` was measured. Neither changes emulation.

## 6. Windows build toolchain note

MSVC 19.51 has a superlinear optimizer case on one of this title's 7 MB
generated translation units, even with `/O1 /Ob1`; it can spend tens of
minutes on that file.  The supported Windows build in this project therefore
uses **clang-cl with the MSVC ABI and the installed Windows SDK**, driven by
Ninja (`scripts/build-windows.ps1`).  The output is a normal native Windows
x64 executable linked against the MSVC runtime.  `-Msvc` selects the Visual
Studio/MSVC generator for comparison; expect the affected file to be slow.
This is a compiler behavior, not a game-specific patch.

No other upstream behavior was changed. Upstream MIT licensing and notices
are unchanged.
