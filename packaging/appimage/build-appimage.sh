#!/usr/bin/env bash
# Build the Linux x86_64 player and package it as a Steam Deck AppImage.
#
# Prerequisites: gcc, g++, cmake 3.21+, make, libsdl2-dev, wget, python3.
# Your ROMs are never bundled. The AppImage contains only the recompiled
# player and its runtime libraries.
#
# Usage: ./packaging/appimage/build-appimage.sh [ROM_DIR]
# Default ROM_DIR=$ROOT/roms; output dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ROMS="${1:-$ROOT/roms}"
BUILD="$ROOT/build-linux"
APPDIR="$BUILD/AppDir"
OUT="$ROOT/dist/steamdeck/RBFF2-SteamDeck-x86_64.AppImage"
DOC="$APPDIR/usr/share/doc/rbff2"

echo "== configure/build (Release) =="
cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release "-DRBFF2_ROM_DIR=$ROMS"
cmake --build "$BUILD" --parallel "$(nproc)"

echo "== assemble AppDir =="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/256x256/apps" \
         "$DOC/LICENSES"
cp "$BUILD/RBFF2" "$APPDIR/usr/bin/RBFF2"
strip --strip-unneeded "$APPDIR/usr/bin/RBFF2" 2>/dev/null || true

# Bundle the SDL2 the build linked against. Do not bundle glibc, libstdc++,
# libgcc or the graphics stack: SteamOS provides those, and bundling them is
# a common source of AppImage breakage.
SDL=$(ldd "$BUILD/RBFF2" | awk '/libSDL2-2\.0\.so\.0/{print $3; exit}')
if [ -n "$SDL" ]; then cp "$SDL" "$APPDIR/usr/lib/"; fi

python3 "$ROOT/packaging/appimage/make_icon.py"
cp "$ROOT/packaging/appimage/rbff2.png" "$APPDIR/rbff2.png"
cp "$ROOT/packaging/appimage/rbff2.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/rbff2.png"
cp "$ROOT/packaging/appimage/rbff2.desktop" "$APPDIR/rbff2.desktop"
cp "$ROOT/packaging/appimage/rbff2.desktop" "$APPDIR/usr/share/applications/rbff2.desktop"
cp "$ROOT/packaging/appimage/README.txt" "$DOC/README.txt"
cp "$ROOT/LICENSE" "$DOC/LICENSE.txt"
cp "$ROOT/LICENSE-STATUS.md" "$DOC/LICENSE-STATUS.md"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$DOC/THIRD_PARTY_NOTICES.md"
cp "$ROOT/docs/rom-layout.md" "$DOC/ROM-LAYOUT.md"
cp "$ROOT/neogeorecomp/LICENSE" "$DOC/LICENSES/neogeorecomp.txt"
cp "$ROOT/neogeorecomp/NOTICE" "$DOC/LICENSES/neogeorecomp-NOTICE.txt"
cp "$ROOT/neogeorecomp/LICENSES/"*.txt "$DOC/LICENSES/"
cp "$ROOT/packaging/appimage/SDL2.txt" "$DOC/LICENSES/SDL2.txt"

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Find a ROM directory beside the AppImage or in the usual Deck locations,
# unless the user passed --rom-path explicitly.
has_rom=0
for a in "$@"; do [ "$a" = "--rom-path" ] && has_rom=1; done
if [ "$has_rom" = 0 ]; then
    here=""
    [ -n "${APPIMAGE:-}" ] && here=$(dirname "$APPIMAGE")
    for d in "$here/roms" "$here/roms/rbff2" \
             "$HOME/Emulation/roms/rbff2" "$HOME/Emulation/roms/neogeo" \
             "$HOME/roms/rbff2" "$HOME/roms"; do
        if [ -d "$d" ]; then set -- --rom-path "$d" "$@"; has_rom=1; break; fi
    done
fi

# Steam Deck / Gaming Mode expects a fullscreen game. Respect an explicit
# --headless, --fullscreen or --scale.
add_fs=1
for a in "$@"; do
    case "$a" in --headless|--fullscreen|--scale) add_fs=0;; esac
done
[ "$add_fs" = 1 ] && set -- --fullscreen "$@"

exec "$HERE/usr/bin/RBFF2" "$@"
EOF
chmod +x "$APPDIR/AppRun"

echo "== appimagetool =="
mkdir -p "$ROOT/dist/steamdeck"
TOOL="${APPIMAGETOOL:-$BUILD/appimagetool.AppImage}"
if [ ! -x "$TOOL" ]; then
    wget -q -O "$TOOL" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$TOOL"
fi
ARCH=x86_64 "$TOOL" --appimage-extract-and-run --no-appstream "$APPDIR" "$OUT"
chmod +x "$OUT"
cp "$ROOT/packaging/appimage/README.txt" "$ROOT/dist/steamdeck/README.txt"
cp "$ROOT/THIRD_PARTY_NOTICES.md" "$ROOT/dist/steamdeck/THIRD_PARTY_NOTICES.md"
echo "wrote $OUT"
