#!/bin/sh -ue

## Set SSH agent variables.
# . "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
  "git@github.com:trilinos/Trilinos.git" \
  "$ORIG_DIR"

VERSION=$(grep "Trilinos_VERSION " "$ORIG_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
  "git://anonscm.debian.org/git/debian-science/packages/trilinos.git" \
  "$DEBIAN_DIR"

# sed -i '/libhdf5-openmpi-dev/d' "$DIR/debian/control"
# sed -i '/HDF5/d' "$DIR/debian/rules"
# sed -i '/libsuperlu-dev/d' "$DIR/debian/control"
# sed -i '/SuperLU/d' "$DIR/debian/rules"
# cd "$DIR" && git commit -a -m "update debian"
#
# # trusty
# "$HOME/rcs/launchpadtools/tools/launchpad-submit" \
#   --directory "$DIR" \
#   --ubuntu-releases trusty \
#   --version-override "$FULL_VERSION" \
#   --version-append-hash \
#   --ppa nschloe/trilinos-nightly \
#   --debuild-params="-p$THIS_DIR/mygpg" \
#   --debfullname "Nico Schlömer" \
#   --debemail "nico.schloemer@gmail.com" \
#   "$@"
#
# rm -rf "$DIR"
#
# # submit for the rest
# DIR=$(mktemp -d)
#
# FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"
#
# "$HOME/rcs/launchpadtools/tools/create-debian-repo" \
#   --orig "git@github.com:trilinos/Trilinos.git" \
#   --debian "git://anonscm.debian.org/git/debian-science/packages/trilinos.git" \
#   --out "$DIR"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/trilinos-nightly \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"
#  --debuild-params="-p$THIS_DIR/mygpg" \

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
