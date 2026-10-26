# Third-Party Notices

This project is a native static recompilation of **Real Bout Fatal Fury 2 -
The Newcomers** (SNK, 1998), built on the
[NeoGeoRecomp](https://github.com/sp00nznet/neogeorecomp) toolkit.

The PolyForm Noncommercial License 1.0.0 in `LICENSE` applies **only** to the
original project code authored for this port: `src/`, `CMakeLists.txt`, the
build and packaging scripts, the tests and the documentation. It does not
apply to any upstream or third-party component, and it does not apply to
SNK's game or system ROM data.

## Upstream toolkit

### NeoGeoRecomp

- Copyright (c) 2026 sp00nznet
- MIT License — see `neogeorecomp/LICENSE`
- Pinned commit: `af96b2b4b39b42b392b17bcaa6a74a5f27088202` (v0.2.0)
- Local generic changes for this port are documented in
  `docs/toolkit-patches.md`; the upstream MIT license still covers the
  modified files.

## Bundled third-party components

These are git submodules of `neogeorecomp/ext/`; their verbatim licenses are
in `neogeorecomp/LICENSES/` and are copied into every binary distribution.

| Component | Author / copyright | License | Use |
|---|---|---|---|
| [Musashi](https://github.com/kstenerud/Musashi) | Copyright (c) 1998-2001 Karl Stenerud | MIT | 68000 fallback interpreter and `--verify` oracle |
| [superzazu/z80](https://github.com/superzazu/z80) | Copyright (c) 2019 Nicolas Allemand | MIT | Z80 sound CPU |
| [ymfm](https://github.com/aaronsgiles/ymfm) | Copyright (c) 2021 Aaron Giles | BSD 3-Clause | YM2610 FM/SSG/ADPCM synthesis |
| [SDL2](https://libsdl.org/) | Copyright (c) 1997-2025 Sam Lantinga and SDL contributors | zlib License | Window, audio, keyboard and gamepad input |

The Windows build ships `SDL2.dll` from the official SDL2 2.32.10 VC
development package. Its zlib license is reproduced in
`dist/windows/RBFF2-Windows-x64/LICENSES/SDL2.txt`. The Microsoft Visual C++
runtime DLLs are redistributed under the Microsoft Visual Studio
redistributable terms.

The Linux AppImage bundles the host's `libSDL2-2.0.so.0`; its license is
included in the AppImage under `/usr/share/doc/rbff2/LICENSES/`.

## Game data

No SNK game ROMs, Neo Geo BIOS files, or C source generated from them are
included in this repository or its binary distributions. You must supply
your own legally obtained MAME `rbff2` set and Neo Geo system ROMs. Generated
C code is written only into your local build directory and is never
committed or redistributed.

Real Bout Fatal Fury 2, The Newcomers, Neo Geo, MVS and AES are trademarks
of SNK Corporation. This project is not affiliated with or endorsed by SNK.
