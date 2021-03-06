#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Some CGAL scripts do indeed assume that the directory is called `trunk`
CLONE_DIR="$TMP_DIR/trunk"
CACHE="$HOME/.cache/repo/cgal"
git -C "$CACHE" pull || git clone "https://github.com/CGAL/cgal.git" "$CACHE"
git clone --shared "$CACHE" "$CLONE_DIR"

# extract version number
cd "$CLONE_DIR"
MAJOR=$(cat "$CLONE_DIR/Maintenance/release_building/MAJOR_NUMBER")
MINOR=$(cat "$CLONE_DIR/Maintenance/release_building/MINOR_NUMBER")
PATCH=$(cat "$CLONE_DIR/Maintenance/release_building/BUGFIX_NUMBER")
VERSION="CGAL-$MAJOR.$MINOR.$PATCH"
# # `git describe` returns something like releases/CGAL-4.10-1997-g82b2e0f337.
# # Extract "CGAL-4.10" from that.
# VERSION=$(git describe | sed 's/[^\/]*\/\(CGAL-[0-9]\+\.[0-9]\+\).*/\1/')

# Create the release dir
cd "$TMP_DIR"
"./trunk/Scripts/developer_scripts/create_internal_release" -r "$VERSION" "$CLONE_DIR"
# cd "$TMP_DIR/tmp/"
# tar xf CGAL-last.tar.gz
#TARFILE=$(cat "$TMP_DIR/tmp/LATEST")
#DIRECTORY="$TMP_DIR/tmp/${TARFILE%.tar.gz}"
ORIG_DIR="$TMP_DIR/orig"
mv "$VERSION" "$ORIG_DIR"

VERSION=$(cat "$ORIG_DIR/VERSION")
FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"

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
  --ubuntu-releases xenial zesty artful bionic \
  --launchpad-login nschloe \
  --ppa nschloe/cgal-nightly \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --update-patches \
  --debuild-params="-p$THIS_DIR/mygpg"
