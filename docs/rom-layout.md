# ROM layout and validation

Game: **Real Bout Fatal Fury 2 - The Newcomers** (MVS), MAME set `rbff2`,
NGH-240.

The layout below was taken from MAME's `src/mame/snk/neogeo.cpp`
(`ROM_START( rbff2 )`, MVS version) and verified byte for byte against the
supplied archive. The P ROMs are stored 16-bit word-swapped (`swap = 1`).
This is a normal, unencrypted MVS cartridge: no NEO-SMA/NEO-CMC protection,
no security chip, no special banking. It uses the standard 1 MB bank window
(`$2FFFF0`), with four banks in the 4 MB banked image.

## Program ROM

| File | Size | Load address | CRC32 | SHA1 |
|---|---:|---:|---|---|
| `240-p1.p1` | 1,048,576 | `$000000` | `80e41205` | `8f83eb8ff54be4ec40f8a0dd2cbe56c54908d00a` |
| `240-p2.sp2` | 4,194,304 | `$100000` | `960aa88d` | `3d9e785891871af90313f178dca2724633406674` |

Total P ROM: `$500000` (5 MB) = 1 MB fixed bank + 4 MB banked area.
The cart header at `$100` contains `NEO-GEO`, NGH `0240`, P ROM size
`$00500000`, and the four entry-point `JMP`s.

## C ROMs

The renderer receives three pairs, byte-interleaved (even byte from the
first file):

| Pair | Files | Size each | Destination |
|---|---|---:|---:|
| 1 | `240-c1.c1`, `240-c2.c2` | 8,388,608 | `$0000000` |
| 2 | `240-c3.c3`, `240-c4.c4` | 8,388,608 | `$1000000` |
| 3 | `240-c5.c5`, `240-c6.c6` | 8,388,608 | `$2000000` |

Total after pairing: `$3000000` (48 MB). CRC32/SHA1 matched MAME:
`effac504`/`e36a96e7…`, `ed182d44`/`a9fc0a3a…`, `22e0330a`/`0fe7f6a8…`,
`c19a07eb`/`139eac8b…`, `244dff5a`/`15654815…`, `4609e507`/`bb17f50a…`.

## Fixed layer, sound and samples

| File | Size | CRC32 | SHA1 |
|---|---:|---|---|
| `240-s1.s1` | 131,072 | `da3b40de` | `e6bf74e057ac6fe1f249a7547f13ba7fbc694561` |
| `240-m1.m1` | 262,144 | `ed482791` | `1f54a45967cb7842c33aa24be322c9f33ff75ac3` |
| `240-v1.v1` | 4,194,304 | `f796265a` | `736dff37eb91fc856b4d189249fb0de9b6c0813a` |
| `240-v2.v2` | 4,194,304 | `2cb3f3bb` | `697e677890892f4b028c9a27c66809ca0a8a9b18` |
| `240-v3.v3` | 4,194,304 | `8fe1367a` | `093d7a4ac2b54ad7ffb2dc316fe29415f7a99535` |
| `240-v4.v4` | 2,097,152 | `996704d8` | `0bf7a1d0660199dedf3c25be757eeab75cc6147e` |

V ROM total: `$E00000` (14 MB), ADPCM-A/B sample data for the YM2610.

## Required system ROMs

Taken from the MAME `neogeo` set. `sp-s2.sp1` is the default (MVS
Asia/Europe v2); `--bios` can select another supported 128 KB MVS BIOS from
the same directory.

| File | Size | CRC32 | SHA1 |
|---|---:|---|---|
| `sp-s2.sp1` | 131,072 | `9036d879` | `4f5ed7105b7128794654ce82b51723e16e389543` |
| `sfix.sfix` | 131,072 | `c2ea0cfd` | `fd4a618cdcdbf849374f0a50dd8efe9dbab706c3` |
| `sm1.sm1` | 131,072 | `94416d67` | `42f9d7ddd6c0931fd64226a60dc73602b2819dcf` |
| `000-lo.lo` | 131,072 | `5a86cff2` | `5992277debadeb64d1c1c64b0a92d9293eaf7e4a` |

All four are required even when the game uses the BIOS fix layer and sound
driver: the BIOS itself boots from `sp-s2.sp1`, and `000-lo.lo` supplies the
sprite vertical-shrink table.

## Unzipping

```bash
mkdir -p roms
unzip rbff2.zip -d roms
unzip neogeo.zip -d roms
```

The runtime expects flat files in `--rom-path`. The `roms/neogeo/`
subdirectory produced by some unzip layouts is not read automatically.

## What is not distributed

Neither the repository nor the Windows/AppImage packages contain any of the
files above. The recompiled C is generated locally from your dump into
`build-*/generated/` and is ignored by Git.
