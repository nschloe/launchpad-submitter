#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
echo "Working directory: $DIR"
"$HOME/rcs/launchpadtools/tools/create-debian-repo" \
   --orig "https://onelab.info/svn/gmsh/trunk" \
   --debian "git://anonscm.debian.org/git/debian-science/packages/gmsh.git" \
   --out "$DIR"

# get version
MAJOR=$(grep 'set(GMSH_MAJOR_VERSION ' "$DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(GMSH_MINOR_VERSION ' "$DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(GMSH_PATCH_VERSION ' "$DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

sed -i "s/Build-Depends:/Build-Depends: libmetis-dev,/" "$DIR/debian/control"
sed -i "/140_fix_java.patch/d" "$DIR/debian/patches/series"
sed -i "/150_fix_texifile.patch/d" "$DIR/debian/patches/series"
cd "$DIR" && git commit -a -m "update patches"

VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"
"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override-override "$VERSION" \
  --version-append-hash \
  --ppa nschloe/gmsh-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"
