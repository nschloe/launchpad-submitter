#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/trilinos/Trilinos.git" "$ORIG_DIR"

VERSION=$(grep "Trilinos_VERSION " "$ORIG_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

DEBIAN_DIR=$(mktemp -d)
# clone \
#   "git://anonscm.debian.org/git/debian-science/packages/trilinos.git" \
#   "$DEBIAN_DIR"
clone \
  "$HOME/rcs/debian-packages/trilinos/" \
  "$DEBIAN_DIR"

# Explicitly disable Intrepid2 so nightly build will go through.
# To be removed once Intrepid2 is in a release.
sed -i "s/-DTrilinos_ENABLE_Mesquite:BOOL=OFF/-DTrilinos_ENABLE_Mesquite:BOOL=OFF -DTrilinos_ENABLE_Intrepid2:BOOL=OFF/g" "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/trilinos-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
