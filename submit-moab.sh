#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/moab/source-upstream/"
cd "$SOURCE_DIR" && git pull

VERSION=$(grep AC_INIT "$SOURCE_DIR/configure.ac" | sed "s/.*\[MOAB\],\[\([^]]*\)\].*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

# A metis bug prevents us for using that pre-wily.
cd "$SOURCE_DIR/debian"
sed -i "/libmetis-dev/d" control
sed -i "/libparmetis-dev/d" control
sed -i "/ENABLE_METIS/d" rules
sed -i "/ENABLE_PARMETIS/d" rules
sed -i "/MOAB_BUILD_MBPART/d" rules

"$THIS_DIR/launchpad-submitter" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases trusty \
  --version "$FULL_VERSION" \
  --ppa nschloe/moab-nightly \
  "$@"

FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

"$THIS_DIR/launchpad-submitter" \
  --directory "$SOURCE_DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppa nschloe/moab-nightly \
  "$@"
