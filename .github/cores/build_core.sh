#!/bin/bash
# Build one libretro core for the Miyoo Mini (SigmaStar SSD202D, Cortex-A7).
#
# Runs inside the aemiii91/miyoomini-toolchain container.
# Usage: build_core.sh <onion_core_name> <output_dir>
#
# <onion_core_name> is the file name Onion uses, without "_libretro.so"
# (see static/build/RetroArch/.retroarch/cores).

set -euo pipefail

name="$1"
outdir="$(realpath -m "$2")"
mkdir -p "$outdir"

# Toolchain
[ -f /root/.bashrc ] && source /root/.bashrc || true
CROSS="${CROSS_COMPILE:-/opt/miyoomini-toolchain/usr/bin/arm-linux-}"
export CC="${CROSS}gcc" CXX="${CROSS}g++" STRIP="${CROSS}strip"
if [ -x "${CROSS}gcc-ar" ]; then export AR="${CROSS}gcc-ar"; else export AR="${CROSS}ar"; fi
ARM_FLAGS="-marm -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -march=armv7ve"

platform="classic_armv7_a7"
subdir="."
makefile="Makefile"
extra=()
built=""      # file name the core's Makefile produces (default: <name>_libretro.so)
recursive=0
cc_cmdline=1  # pass CC/CXX/AR on the make command line (see below)

case "$name" in
gpsp)
    repo=libretro/gpsp
    platform=miyoomini # gpSP has a dedicated Miyoo Mini target
    built=gpsp_plus_libretro.so
    ;;
gambatte)
    repo=libretro/gambatte-libretro
    makefile=Makefile.libretro
    ;;
fceumm)
    repo=libretro/libretro-fceumm
    makefile=Makefile.libretro
    ;;
nestopia)
    repo=libretro/nestopia
    subdir=libretro
    ;;
snes9x2005_plus)
    repo=libretro/snes9x2005
    extra=(USE_BLARGG_APU=1)
    ;;
mednafen_supafaust)
    repo=libretro/supafaust
    ;;
picodrive)
    repo=libretro/picodrive
    makefile=Makefile.libretro
    recursive=1
    cc_cmdline=0 # builds and runs a host tool (cyclone_gen), so CC must stay overridable
    ;;
genesis_plus_gx)
    repo=libretro/Genesis-Plus-GX
    makefile=Makefile.libretro
    platform=unix # no Cortex-A7 target upstream, pass the CPU flags ourselves
    export CFLAGS="$ARM_FLAGS -O3" CXXFLAGS="$ARM_FLAGS -O3"
    ;;
pcsx_rearmed)
    repo=libretro/pcsx_rearmed
    makefile=Makefile.libretro
    recursive=1
    ;;
mednafen_pce_fast)
    repo=libretro/beetle-pce-fast-libretro
    ;;
fbneo)
    repo=libretro/FBNeo
    subdir=src/burner/libretro
    # No LTO: it makes the toolchain gcc 8.3 crash (ICE in ay8910.c).
    # The classic_armv7_a7 target does not link pthread (needed by sys16_gfx).
    extra=(USE_EXPERIMENTAL_FLAGS=0 LIBS=-lpthread)
    ;;
mame2003_plus)
    repo=libretro/mame2003-plus-libretro
    ;;
*)
    echo "Unknown core: $name" >&2
    exit 1
    ;;
esac

built="${built:-${name}_libretro.so}"
src="$(mktemp -d)/$name"

if [ $recursive -eq 1 ]; then
    git clone --depth 1 --recurse-submodules --shallow-submodules "https://github.com/$repo.git" "$src"
else
    git clone --depth 1 "https://github.com/$repo.git" "$src"
fi

commit=$(git -C "$src" log -1 --format='%h')
date=$(git -C "$src" log -1 --date=short --format='%cd') # git 2.20 in the image: no %cs

cd "$src/$subdir"
# Compilers go on the command line: some Makefiles hardcode CC (snes9x2005
# sets plain gcc, gpSP's miyoomini target a path that does not exist in the
# image), and command-line variables override those assignments.
if [ $cc_cmdline -eq 1 ]; then
    make -f "$makefile" platform="$platform" CC="$CC" CXX="$CXX" AR="$AR" "${extra[@]}" -j"$(nproc)"
else
    make -f "$makefile" platform="$platform" "${extra[@]}" -j"$(nproc)"
fi

# Never ship a host binary by accident
if ! "${CROSS}readelf" -h "$built" | grep -q 'Machine:.*ARM'; then
    echo "ERROR: $built is not an ARM binary" >&2
    file "$built" >&2 || true
    exit 1
fi

"$STRIP" --strip-unneeded "$built"
cp "$built" "$outdir/${name}_libretro.so"
printf '%s\t%s\t%s\t%s\n' "$name" "$repo" "$commit" "$date" > "$outdir/${name}.manifest"

echo "Built ${name}_libretro.so from $repo@$commit ($date)"
file "$outdir/${name}_libretro.so" || true
