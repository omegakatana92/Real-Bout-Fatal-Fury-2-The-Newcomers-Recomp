Real Bout Fatal Fury 2 - The Newcomers
Native static recompilation for Windows x64
===========================================

This folder contains RBFF2.exe, SDL2.dll, the Visual C++ runtime DLLs and
the licenses. It does NOT contain game ROMs or the Neo Geo BIOS.

Quick start
-----------
1. Create a folder named "roms" here (or anywhere) and unzip your legally
   obtained MAME sets into it:

     rbff2.zip  -> 240-p1.p1 240-p2.sp2 240-c1.c1 ... 240-c6.c6
                   240-s1.s1 240-m1.m1 240-v1.v1 ... 240-v4.v4
     neogeo.zip -> sp-s2.sp1 sfix.sfix sm1.sm1 000-lo.lo

   All files must be directly in the same folder. See ROM-LAYOUT.md for
   sizes and hashes.

2. Run RBFF2.exe. It looks for .\roms by default. To use another folder:

     RBFF2.exe --rom-path "D:\NeoGeo\roms"

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

On MVS you must insert a coin before Start does anything. Up to two SDL
GameControllers work; the first is player 1, the second player 2.

Command line
------------
Run RBFF2.exe --help for the full list. Useful options:
  --rom-path DIR        game ROM files (default: roms)
  --bios-path DIR       BIOS files (default: the ROM path)
  --bios FILE           system ROM (default: sp-s2.sp1)
  --fullscreen          start fullscreen (F11 toggles)
  --scale N             window scale (default 3)
  --headless            no window
  --interp              interpreter only
  --verify              compare every recompiled block with Musashi

Notes
-----
* The MVS BIOS is the real sp-s2.sp1 system ROM; there is no BIOS HLE.
* The 68000 program is statically recompiled at build time from your own
  dump. Runtime-computed targets without a native entry use the bundled
  Musashi interpreter.
* Original project code is PolyForm Noncommercial 1.0.0. Upstream
  NeoGeoRecomp (MIT), Musashi (MIT), z80 (MIT), ymfm (BSD-3) and SDL2
  (zlib) keep their own licenses; see LICENSES\.
* Real Bout Fatal Fury 2, Neo Geo, MVS and AES are trademarks of SNK
  Corporation. This project is not affiliated with or endorsed by SNK.
