#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/CGAL/cgal.git" \
  "$ORIG_DIR"

# Create the release dir
cd "$TMP_DIR"
bash "$ORIG_DIR/Scripts/developer_scripts/create_new_release" "$ORIG_DIR" --verbose
cd "$TMP_DIR/tmp/"
tar xf CGAL-last.tar.gz
TARFILE=$(cat "$TMP_DIR/tmp/LATEST")
DIRECTORY="$TMP_DIR/tmp/${TARFILE%.tar.gz}"
if [ ! -d "$DIRECTORY" ]; then
  echo "Couldn't find directory $DIRECTORY."
  exit 1
fi
ORIG_DIR="$DIRECTORY"

VERSION=$(cat "$ORIG_DIR/VERSION")
FULL_VERSION="$VERSION~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
clone \
  --subdirectory=debian/ \
  "https://github.com/nschloe/cgal-debian.git" \
  "$DEBIAN_DIR"

cd "$DEBIAN_DIR"
rename "s/11v5/12/" ./*
rename "s/11/12/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/11v5/12/g" "$i"
  [ -f "$i" ] && sed -i "s/11/12/g" "$i"
done

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty \
  --ppa nschloe/cgal-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"
