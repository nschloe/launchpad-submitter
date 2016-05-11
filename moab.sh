#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
echo "Working directory: $DIR"
"$HOME/rcs/launchpadtools/tools/create-debian-repo" \
   --orig "git@bitbucket.org:fathomteam/moab.git" \
   --out "$DIR"

VERSION=$(grep AC_INIT "$DIR/configure.ac" | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

# # A metis bug prevents us for using that pre-wily.
# cd "$DIR/debian"
# sed -i "/libmetis-dev/d" control
# sed -i "/libparmetis-dev/d" control
# sed -i "/ENABLE_METIS/d" rules
# sed -i "/ENABLE_PARMETIS/d" rules
# sed -i "/MOAB_BUILD_MBPART/d" rules
# 
# "$THIS_DIR/launchpad-submit" \
#   --orig-dir "$SOURCE_DIR" \
#   --debian-dir "$DEBIAN_DIR" \
#   --ubuntu-releases trusty \
#   --version-override "$FULL_VERSION" \
#   --ppa nschloe/moab-nightly \
#   "$@"

FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/moab-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$DIR"
