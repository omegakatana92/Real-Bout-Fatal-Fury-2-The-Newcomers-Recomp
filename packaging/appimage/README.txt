Real Bout Fatal Fury 2 - native static recompilation
====================================================

This AppImage contains the recompiled game, the SDL2 window/audio layer and
the project documentation. It does NOT contain game ROMs or the Neo Geo
BIOS: supply your own legally obtained dump.

Quick start
-----------
1. Put the unzipped MAME "rbff2" set and the "neogeo" system ROMs in a
   folder named "roms" next to the AppImage, or use one of:

     ~/Emulation/roms/rbff2        ~/Emulation/roms/neogeo
     ~/roms/rbff2                  ~/roms

   Or pass --rom-path DIR explicitly.

2. Run the AppImage. It starts fullscreen with the 4:3-ish Neo Geo picture
   pillarboxed on a 1280x800 Steam Deck screen (aspect ratio preserved).

Steam Deck
----------
Desktop Mode: double-click the AppImage (or mark it executable first).
Gaming Mode: add it as a non-Steam game. No launch options are needed; the
AppRun script selects fullscreen automatically. Steam Input's default
gamepad template maps the face buttons to A/B/X/Y, which the player uses as
Neo Geo A/B/C/D. Use the controller's Back button (or the on-screen keyboard
mapping) for COIN, then Start.

Controls
--------
  Arrows / left stick     move
  Z X C V / pad A B X Y   Neo Geo A B C D
  5 / Back                insert coin
  1 / Start               start
  3 / left shoulder       select
  9                       service
  F2                      test switch
  F11                     toggle fullscreen
  Esc                     quit

Notes
-----
* The MVS BIOS is the real sp-s2.sp1 system ROM; there is no BIOS HLE.
* The 68000 program is statically recompiled. Code reached only through
  runtime-computed targets runs in the bundled Musashi interpreter; the
  measured share is reported in the project README and docs/compatibility.md.
* Audio is synthesized from the real Z80 M1 driver and YM2610 V ROMs through
  ymfm and played by SDL2.
* The license of this original project code is PolyForm Noncommercial 1.0.0.
  Upstream NeoGeoRecomp (MIT), Musashi (MIT), z80 (MIT), ymfm (BSD-3) and
  SDL2 (zlib) keep their own licenses. See /usr/share/doc/rbff2/.
* Real Bout Fatal Fury 2, Neo Geo, MVS and AES are trademarks of SNK
  Corporation. This project is not affiliated with or endorsed by SNK.
