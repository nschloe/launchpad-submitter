#!/bin/sh -ue
#
# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git@github.com:dealii/dealii.git" \
   "$ORIG_DIR"

UPSTREAM_VERSION=$(cat "$ORIG_DIR/VERSION")

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git://anonscm.debian.org/git/debian-science/packages/deal.ii.git" \
   "$DEBIAN_DIR"

sed -i "/fix_suitesparse.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/use_local_deal_ico.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/fix_parameter_handler_cxx11.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/use_fPIC_instead_of_fpic.patch/d" "$DEBIAN_DIR/debian/patches/series"

#  --update-patches \
"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/deal.ii-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
