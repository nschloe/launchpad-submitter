#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/mikado"
git -C "$CACHE" pull || git clone "https://github.com/nschloe/mikado.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep "set(Mikado_MAJOR_VERSION " "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep "set(Mikado_MINOR_VERSION " "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep "set(Mikado_PATCH_VERSION " "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases trusty xenial zesty artful \
  --version-override "$VERSION+git$(date +"%Y%m%d")" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/mikado-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
