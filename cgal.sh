#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/CGAL/cgal.git" "$ORIG_DIR"

# Create the release dir
rm -rf /tmp/CGAL-*
rm -rf /tmp/tmp/
rm -f /tmp/release_creation.lock
cd /tmp/
bash "$ORIG_DIR/Scripts/developer_scripts/create_new_release" "$ORIG_DIR" --verbose
cd /tmp/tmp/
echo 1
tar xf CGAL-last.tar.gz
echo 2
TARFILE=$(cat /tmp/tmp/LATEST)
echo 3
DIRECTORY="/tmp/tmp/${TARFILE%.tar.gz}"
echo 4
if [ ! -d "$DIRECTORY" ]; then
  echo "Couldn't find directory $DIRECTORY."
  exit 1
fi
echo 5
ORIG_DIR="$DIRECTORY"

VERSION=$(cat "$ORIG_DIR/VERSION")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR=$(mktemp -d)
clone "git@github.com:nschloe/cgal-debian.git" "$DEBIAN_DIR"

cd "$DEBIAN_DIR/debian"
rename "s/11v5/12/" ./*
rename "s/11/12/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/11v5/12/g" "$i"
  [ -f "$i" ] && sed -i "s/11/12/g" "$i"
done

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety \
  --ppa nschloe/cgal-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
