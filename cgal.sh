#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

CLONE_DIR="$TMP_DIR/clone"
CACHE="$HOME/.cache/repo/cgal"
git -C "$CACHE" pull || git clone "https://github.com/CGAL/cgal.git" "$CACHE"
git clone --shared "$CACHE" "$CLONE_DIR"

# Create the release dir
cd "$TMP_DIR"
"$CLONE_DIR/Scripts/developer_scripts/create_new_release" "$CLONE_DIR"
cd "$TMP_DIR/tmp/"
tar xf CGAL-last.tar.gz
TARFILE=$(cat "$TMP_DIR/tmp/LATEST")
DIRECTORY="$TMP_DIR/tmp/${TARFILE%.tar.gz}"
ORIG_DIR="$TMP_DIR/orig"
mv "$DIRECTORY" "$ORIG_DIR"

VERSION=$(cat "$ORIG_DIR/VERSION")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d")"

DEBIAN_DIR="$ORIG_DIR/debian"
CACHE="$HOME/.cache/repo/cgal-debian"
git -C "$CACHE" pull || git clone "https://github.com/nschloe/cgal-debian.git" "$CACHE"
echo "rsync -a \"$CACHE/\" \"$ORIG_DIR/debian\""
rsync -a "$CACHE/debian" "$ORIG_DIR"

cd "$DEBIAN_DIR"
rename "s/11v5/12/" ./*
rename "s/11/12/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/11v5/12/g" "$i"
  [ -f "$i" ] && sed -i "s/11/12/g" "$i"
done

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial yakkety zesty artful \
  --launchpad-login nschloe \
  --ppa nschloe/cgal-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"
