#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/boost"
git -C "$CACHE" pull || git clone --recursive "https://github.com/boostorg/boost.git" "$CACHE"
# Don't use local `git clone --shared` here since that doesn't consider the
# submodules.
rsync -a "$CACHE/" "$ORIG_DIR"

cd "$ORIG_DIR"
./bootstrap.sh
./bjam headers
# The above commands create the headers as symlinks.
# Follow them <http://superuser.com/a/303574/227453>.
tar -hcf boost.tar boost
rm -rf boost
tar -xf boost.tar
rm -f boost.tar

# FIXME https://svn.boost.org/trac/boost/ticket/12723

UPSTREAM_VERSION=$(grep 'BOOST_VERSION' "$ORIG_DIR/Jamroot" | sed 's/[^0-9]*\([0-9\.]*\).*/\1/' -)
UPSTREAM_VERSION_SHORT=$(echo "$UPSTREAM_VERSION" | sed 's/\([0-9]*\.[0-9]*\).*/\1/' -)

DEBIAN_DIR="$ORIG_DIR/debian"
CACHE="$HOME/.cache/repo/boost-debian"
(cd "$CACHE" && svn up) || svn co "svn://svn.debian.org/pkg-boost/boost/trunk" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_VERSION_SHORT=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_VERSION="$DEBIAN_VERSION_SHORT.0"

cd "$DEBIAN_DIR"
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION_SHORT/$UPSTREAM_VERSION_SHORT/g" "$i"
done

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful bionic \
  --update-patches \
  --version-override "$UPSTREAM_VERSION+git$(date +"%Y%m%d%H%M")" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/boost-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
