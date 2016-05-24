#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "git@bitbucket.org:fenics-project/dolfin.git" "$ORIG_DIR"

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone \
   "git://anonscm.debian.org/git/debian-science/packages/fenics/dolfin.git" \
   "$DEBIAN_DIR"

# sed -i "/slepc-dev/d"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

# cd "$DEBIAN_DIR" && git checkout .
# sed -i "/python-netcdf/d" control
#
# rm -rf "$DIR"
# "$HOME/rcs/launchpadtools/tools/create-debian-repo" \
#   --orig "$SOURCE_DIR" \
#   --debian "$DEBIAN_DIR" \
#   --out "$DIR"
##
# launchpad-submit \
#   --directory "$DIR" \
#   --ubuntu-releases xenial yakkety \
#   --version-override "$FULL_VERSION" \
#   --ppa nschloe/fenics-nightly \
#   --debuild-params="-p$THIS_DIR/../mygpg" \
#   --submit-id "Nico Schlömer <nico.schloemer@gmail.com>" \
#   "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
