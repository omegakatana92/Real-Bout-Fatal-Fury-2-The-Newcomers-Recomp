# License status

Confirmed by the project owner on 2026-10-26: the original code authored for
this port is licensed under **PolyForm Noncommercial 1.0.0**.

## Scope

| Material | License | Notes |
|---|---|---|
| `src/`, `CMakeLists.txt`, `scripts/`, `packaging/`, `tests/`, `docs/`, project `README.md` | PolyForm Noncommercial 1.0.0 (`LICENSE`) | Original work for this port |
| `neogeorecomp/` toolkit | MIT (`neogeorecomp/LICENSE`) | Upstream, copyright sp00nznet; local generic fixes documented in `docs/toolkit-patches.md` stay under MIT |
| Musashi | MIT (`neogeorecomp/LICENSES/Musashi.txt`) | Upstream submodule |
| superzazu/z80 | MIT (`neogeorecomp/LICENSES/z80.txt`) | Upstream submodule |
| ymfm | BSD-3-Clause (`neogeorecomp/LICENSES/ymfm.txt`) | Upstream submodule |
| SDL2 | zlib (`packaging/*/SDL2.txt`) | Bundled DLL/AppImage library |
| Microsoft VC++ runtime DLLs | Microsoft redistributable terms | Windows package only |
| SNK game ROMs, Neo Geo BIOS, ROM-derived C | Not distributed | User supplies legally obtained ROMs; the recompiler writes C locally |

## What the license does and does not cover

- PolyForm Noncommercial permits personal, hobby, research, educational and
  other noncommercial use. It does **not** grant commercial distribution or
  commercial use rights. A separate license from the copyright holder would
  be required for those.
- Upstream and third-party files are **not** relicensed under PolyForm. Their
  original notices and license texts are preserved and copied into binary
  distributions.
- The project does not distribute any SNK ROM data or generated C derived
  from it. The prebuilt players contain only the recompilation runtime and
  the original project code; they still require the user's ROMs to run.
- Real Bout Fatal Fury 2, The Newcomers, Neo Geo, MVS and AES are trademarks
  of SNK Corporation. This project is not affiliated with or endorsed by SNK.
- Whether a recompiled binary or its distribution requires additional rights
  from the game's copyright holder can depend on jurisdiction and on how the
  binary is used. This document records the project's licensing choices; it
  is not legal advice. If you intend to distribute builds, review that
  question with a qualified professional.
