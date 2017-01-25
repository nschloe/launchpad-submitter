#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
# cleanup() { rm -rf "$TMP_DIR"; }
# trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/trilinos"
git -C "$CACHE" pull || git clone "https://github.com/trilinos/Trilinos.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep "Trilinos_VERSION " "$ORIG_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

# CACHE="$HOME/.cache/repo/trilinos-debian"
# git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/trilinos.git" "$CACHE"
# rsync -a "$CACHE/debian" "$ORIG_DIR"
rsync -a "$HOME/rcs/debian/trilinos/debian" "$ORIG_DIR"

#sed -i "s/-DCMAKE_SKIP_INSTALL_RPATH:BOOL=ON/-DCMAKE_SKIP_INSTALL_RPATH:BOOL=ON -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=OFF -DCMAKE_SHARED_LINKER_FLAGS:STRING=\"-Wl,--no-undefined\"/g" "$DEBIAN_DIR/rules"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
