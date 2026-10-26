# Testing

All commands are run from the project root. `ROMS` is a directory containing
the 14 `rbff2` files and the four required `neogeo` BIOS files (see
`docs/rom-layout.md`).

## 1. ROM validation

```bash
python3 - <<'PY'
import zlib, hashlib, os
want = {
 '240-p1.p1':'80e41205','240-p2.sp2':'960aa88d','240-s1.s1':'da3b40de',
 '240-m1.m1':'ed482791','240-c1.c1':'effac504','240-c2.c2':'ed182d44',
 '240-c3.c3':'22e0330a','240-c4.c4':'c19a07eb','240-c5.c5':'244dff5a',
 '240-c6.c6':'4609e507','240-v1.v1':'f796265a','240-v2.v2':'2cb3f3bb',
 '240-v3.v3':'8fe1367a','240-v4.v4':'996704d8',
 'sp-s2.sp1':'9036d879','sfix.sfix':'c2ea0cfd','sm1.sm1':'94416d67',
 '000-lo.lo':'5a86cff2',
}
d = os.environ.get('ROMS', 'roms')
for name, crc in want.items():
    p = os.path.join(d, name)
    data = open(p, 'rb').read()
    got = '%08x' % (zlib.crc32(data) & 0xffffffff)
    print(('OK  ' if got == crc else 'BAD ') + name, len(data), got)
PY
```

## 2. Interpreter boot

```bash
./build-linux/RBFF2 --headless --interp --rom-path "$ROMS" --frames 3600 \
    --screenshot 600:bios-logo.png --screenshot 3599:attract.png
```

Expected: Neo Geo logo, then the game's attract demonstration. No crash.
This checks the board model independently of the recompiler.

## 3. Native build and verification

```bash
./build-linux/RBFF2 --headless --verify --rom-path "$ROMS" --frames 6000 \
    --input tests/coin_start.txt
```

Expected: `[verify] ... 0 mismatches`, and the `[exec]` line reports the
native block count and any interpreted instructions.

Compare screenshots with the interpreter build at the same frame numbers:

```bash
# native
./build-linux/RBFF2 --headless --rom-path "$ROMS" --frames 3600 \
    --screenshot 3599:native.png
# interpreter
./build-linux/RBFF2 --headless --interp --rom-path "$ROMS" --frames 3600 \
    --screenshot 3599:interp.png
cmp native.png interp.png && echo identical
```

## 4. Coverage profile

```bash
cmake --build build-linux --target profile
cmake --build build-linux --parallel
./build-linux/RBFF2 --headless --rom-path "$ROMS" --frames 6000 \
    --input tests/coin_start.txt
```

The `profile` target writes runtime-discovered entry points to
`build-linux/entries.txt`; the rebuild recompiles them. Repeat until the
`[exec]` line shows `interpreted instructions 0` for the tested scripts, or
document what remains.

To list the most expensive interpreted entry points:

```bash
NG_PROFILE=1 ./build-linux/RBFF2 --headless --rom-path "$ROMS" --frames 6000
```

## 5. Gameplay and audio capture

```bash
./build-linux/RBFF2 --headless --rom-path "$ROMS" --frames 18000 \
    --input tests/play_long.txt --wav playback.wav \
    --screenshot 5000:menu.png --screenshot 9000:fight.png \
    --screenshot 17000:fight2.png
```

Check: title and menus render, coin and start work, a match begins, controls
respond, sprites/background/fix layer/palettes are stable, and `playback.wav`
has non-silent audio (for example `ffmpeg -i playback.wav -af volumedetect -f null -`).

## 6. Windows

```powershell
scripts\fetch-deps.ps1
scripts\build-windows.ps1 -RomDir C:\path\to\roms -Test
.\dist\windows\RBFF2-Windows-x64\RBFF2.exe --rom-path C:\path\to\roms
```

Check windowed launch, keyboard, an Xbox-compatible controller, audio and
F11. The staged folder must contain `RBFF2.exe`, `SDL2.dll`, the VC runtime
DLLs, `README.txt` and the licenses, and no ROMs.

## 7. Linux / Steam Deck AppImage

```bash
./packaging/appimage/build-appimage.sh "$ROMS"
./dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage --headless \
    --rom-path "$ROMS" --frames 900
```

Then on a Linux desktop or Steam Deck:

```bash
./dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage --rom-path "$ROMS"
```

Check fullscreen, 1280x800 pillarboxing (no stretch), audio, controller
mapping, coin/start, and exit. In Gaming Mode, add the AppImage as a
non-Steam game and launch it with Steam Input enabled.

`ldd` on the extracted AppDir binary must show no missing libraries and no
unexpected bundled glibc:

```bash
./RBFF2-SteamDeck-x86_64.AppImage --appimage-extract
ldd squashfs-root/usr/bin/RBFF2
find squashfs-root -name 'libc.so*' -o -name 'libstdc++*'
```

## Determinism

Input scripts are deterministic: the same script and ROMs produce identical
frames on Windows and Linux. That is the basis of the native/interpreter
screenshot comparison above.
