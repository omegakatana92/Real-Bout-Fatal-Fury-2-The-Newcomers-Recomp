#!/usr/bin/env python3
"""Draw an original 256x256 icon for the RBFF2 recompilation.

No SNK artwork is used: a dark arena backdrop, a golden diagonal band and
block letters drawn from a tiny bitmap font.
"""
import os
import struct
import zlib

W = H = 256
px = bytearray(W * H * 3)


def put(x, y, r, g, b):
    if 0 <= x < W and 0 <= y < H:
        i = (y * W + x) * 3
        px[i] = r
        px[i + 1] = g
        px[i + 2] = b


# dark blue-black background with a subtle vertical gradient
for y in range(H):
    for x in range(W):
        put(x, y, 8 + y // 24, 10 + y // 18, 20 + y // 12)

# diagonal gold band
for y in range(H):
    for x in range(W):
        if 40 <= (x + y) % 256 <= 72:
            put(x, y, 232, 176, 28)

# panel behind the letters
for y in range(78, 186):
    for x in range(22, 234):
        put(x, y, 12, 12, 16)

FONT = {
    'R': ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    'B': ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    '2': ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
}
text = "RB2"
scale = 14
tw = (len(text) * 5 + (len(text) - 1)) * scale
tx = (W - tw) // 2
ty = (H - 7 * scale) // 2
for ci, ch in enumerate(text):
    for gy, row in enumerate(FONT[ch]):
        for gx, bit in enumerate(row):
            if bit == '1':
                for yy in range(scale):
                    for xx in range(scale):
                        put(tx + (ci * 6 + gx) * scale + xx, ty + gy * scale + yy, 244, 244, 238)

# red roundel accent
cx, cy, rad = 208, 206, 24
for y in range(cy - rad, cy + rad + 1):
    for x in range(cx - rad, cx + rad + 1):
        d = (x - cx) ** 2 + (y - cy) ** 2
        if d <= rad * rad:
            put(x, y, 196, 28, 24 if d > (rad - 4) ** 2 else 236)

raw = bytearray()
for y in range(H):
    raw.append(0)
    raw += px[y * W * 3:(y + 1) * W * 3]


def chunk(t, d):
    return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xFFFFFFFF)


out = b'\x89PNG\r\n\x1a\n'
out += chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0))
out += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
out += chunk(b'IEND', b'')
path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rbff2.png")
with open(path, 'wb') as f:
    f.write(out)
print(path)
