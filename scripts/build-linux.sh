# Build the native Linux x86_64 player.
#
# Usage: ./scripts/build-linux.sh [ROM_DIR]
# Default ROM_DIR=$ROOT/roms.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROMS="${1:-$ROOT/roms}"
cmake -S "$ROOT" -B "$ROOT/build-linux" -DCMAKE_BUILD_TYPE=Release "-DRBFF2_ROM_DIR=$ROMS"
cmake --build "$ROOT/build-linux" --parallel "$(nproc)"
echo "built $ROOT/build-linux/RBFF2"
