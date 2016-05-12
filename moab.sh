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
