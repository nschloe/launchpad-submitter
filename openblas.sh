#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git@github.com:xianyi/OpenBLAS.git" \
   "$ORIG_DIR"

MAJOR=$(grep 'set(OpenBLAS_MAJOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(OpenBLAS_MINOR_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(OpenBLAS_PATCH_VERSION ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git://anonscm.debian.org/git/debian-science/packages/openblas.git" \
   "$DEBIAN_DIR"

sed -i "/kfreebsd.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/always-run-testsuite.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/no-embedded-lapack.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/shared-blas-lapack.patch/d" "$DEBIAN_DIR/debian/patches/series"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/openblas-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
