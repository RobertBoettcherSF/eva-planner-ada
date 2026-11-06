#!/bin/sh
set -e
cd "$(dirname "$0")/.."
ROOT=$PWD
CFA=/workspace/core-flight-ada
T=$CFA/toolchain/usr
LD=$CFA/toolchain/wasm-ld
CLANG=/tmp/wasi-sdk-24.0-x86_64-linux/bin/clang
export LD_LIBRARY_PATH="$CFA/toolchain/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
rm -rf obj/wasm
mkdir -p obj/wasm/src obj/wasm/src/browser dist

for F in src/eva_plan.ads src/eva_plan-viz.ads src/eva_plan-viz.adb \
         src/eva_plan-api.ads src/eva_plan-api.adb; do
  dest=obj/wasm/$F
  mkdir -p "$(dirname "$dest")"
  sed 's/pragma Assertion_Policy (Check);/pragma Assertion_Policy (Ignore);/g' "$F" > "$dest"
done

cat > obj/wasm/src/browser/last_chance.c << 'C'
void __gnat_last_chance_handler (char *file, int line) {
  (void)file; (void)line; __builtin_trap();
}
void system__assertions__raise_assert_failure (void *msg, void *file, int line) {
  (void)msg; (void)file; (void)line; __builtin_trap();
}
C

CC="$T/bin/llvm-gcc"
FLAGS="-c --target=wasm32 -O2 -gnat2012 -gnatp -gnatwa --RTS=$T/lib/rts-native -I$ROOT/obj/wasm/src"

cd obj/wasm
echo "compile eva_plan-viz.adb"
$CC $FLAGS src/eva_plan-viz.adb
echo "compile eva_plan-api.adb"
$CC $FLAGS src/eva_plan-api.adb
echo "compile last_chance stub"
$CLANG -c --target=wasm32 -O2 src/browser/last_chance.c -o last_chance.o

mkdir -p rts && (cd rts && ar x "$T/lib/rts-native/adalib/libgnat.a")
for M in s-memcop.o s-memmov.o s-memset.o; do cp rts/$M .; done

$LD --no-entry --strip-all \
  --export=eva_init \
  --export=eva_viz_start --export=eva_viz_tick --export=eva_viz_frame \
  --export=eva_viz_width --export=eva_viz_height \
  --export=eva_version_len --export=eva_version_byte \
  --initial-memory=16777216 \
  -o eva_plan.wasm \
  eva_plan-viz.o eva_plan-api.o \
  s-memcop.o s-memmov.o s-memset.o last_chance.o

echo "WASM bytes: $(wc -c < eva_plan.wasm)"
cd "$ROOT"
python3 "$ROOT/tools/embed-wasm.py"
