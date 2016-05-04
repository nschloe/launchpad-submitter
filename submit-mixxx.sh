#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/mixxx/pristine/"
VERSION=$(grep "define VERSION" "$SOURCE_DIR/src/defs_version.h" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DIR="/tmp/mixxx"
rm -rf "$DIR"
cp -r "$SOURCE_DIR" "$DIR"
rm -rf "$DIR/.git" "$DIR/.gitignore"
cp -r "$HOME/rcs/debian-packages/mixxx/debian/" "$DIR"
rm -rf "$DIR/debian/.git" "$DIR/debian/.gitignore"
cd "$DIR/debian"
sed -i "/0004-soundtouch.patch/d" patches/ubuntu.series
sed -i "/0005-hidapi.patch/d" patches/ubuntu.series
sed -i "/0006-opengles.patch/d" patches/ubuntu.series
sed -i "/1001-buildsystem.patch/d" patches/ubuntu.series
sed -i "s/libsoundtouch-dev (>= 1.8.0)/libsoundtouch-dev (>= 1.7.1)/g" control
cd "$DIR"
git init
git add *
git commit -a -m "Import source, debian" --quiet

if [ `git log --pretty=format:'%T'` = `cat "$THIS_DIR/mixxx-nightly.dat"` ]; then
  echo "Already submitted."
  exit 1
fi

"$THIS_DIR/debian-update-patches" "$DIR"

"$THIS_DIR/launchpad-submit"\
  --directory "$DIR" \
  --ubuntu-releases trusty wily xenial yakkety \
  --version "$FULL_VERSION" \
  --ppas nschloe/mixxx-nightly \
  --submit-hashes-file "$THIS_DIR/mixxx-nightly.dat" \
  "$@"

# Update hash
git log --pretty=format:'%T' > "$THIS_DIR/mixxx-nightly.dat"
