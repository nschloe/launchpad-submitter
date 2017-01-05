#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/boostorg/boost.git" "$ORIG_DIR"

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

DEBIAN_DIR=$(mktemp -d)
clone "svn://svn.debian.org/pkg-boost/boost/trunk" "$DEBIAN_DIR"
DEBIAN_VERSION_SHORT=$(head -n 1 "$DEBIAN_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_VERSION="$DEBIAN_VERSION_SHORT.0"

cd "$DEBIAN_DIR/debian"
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION_SHORT/$UPSTREAM_VERSION_SHORT/g" "$i"
done

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases yakkety zesty \
  --update-patches \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/boost-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
