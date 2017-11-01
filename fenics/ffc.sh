#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/ffc"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/ffc.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep -i 'version =' "$ORIG_DIR/setup.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/ffc-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/ffc.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "/ufc-1.pc/d" "$DEBIAN_DIR/rules"
# Untie the dependencies from the exact version
sed -i "s/python-fiat.*/python-fiat,/g" "$DEBIAN_DIR/control"
sed -i "s/python3-fiat.*/python3-fiat,/g" "$DEBIAN_DIR/control"
sed -i "s/python-instant.*/python-instant,/g" "$DEBIAN_DIR/control"
sed -i "s/python3-instant.*/python3-instant,/g" "$DEBIAN_DIR/control"
sed -i "s/python-ufl.*/python-ufl,/g" "$DEBIAN_DIR/control"
sed -i "s/python3-ufl.*/python3-ufl,/g" "$DEBIAN_DIR/control"
sed -i "s/python-dijitso.*/python-dijitso,/g" "$DEBIAN_DIR/control"
sed -i "s/python3-dijitso.*/python3-dijitso,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases zesty artful bionic \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
