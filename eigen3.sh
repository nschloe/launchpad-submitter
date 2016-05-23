#!/bin/sh -ue
#
# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git@github.com:RLovelett/eigen.git" \
   "$ORIG_DIR"


MAJOR=$(grep '#define EIGEN_WORLD_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep '#define EIGEN_MAJOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep '#define EIGEN_MINOR_VERSION ' "$ORIG_DIR/Eigen/src/Core/util/Macros.h" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git://anonscm.debian.org/git/debian-science/packages/eigen3.git" \
   "$DEBIAN_DIR"

sed -i "/09_fix_1144.patch/d" "$DEBIAN_DIR/debian/patches/series"
#sed -i "/use_local_deal_ico.patch/d" "$DEBIAN_DIR/debian/patches/series"
#sed -i "/fix_parameter_handler_cxx11.patch/d" "$DEBIAN_DIR/debian/patches/series"
#sed -i "/use_fPIC_instead_of_fpic.patch/d" "$DEBIAN_DIR/debian/patches/series"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$UPSTREAM_VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/eigen-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
