#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
finish() { rm -rf "$TMP_DIR"; }
trap finish EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/dijitso"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/dijitso.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION=$(grep 'version =' "$ORIG_DIR/setup.py" | sed 's/[^0-9]*\([0-9]*\.[0-9]\.[0-9]\).*/\1/')
FULL_VERSION="$VERSION~git$(date +"%Y%m%d%H%M")"

# <https://bitbucket.org/fenics-project/dijitso/issues/27/python3-distributionnotfound-the-dijitso>
sed -i "s/__version__ = get_distribution('dijitso').version/__version__ = '$VERSION'/g" "$ORIG_DIR/dijitso/__init__.py"

CACHE="$HOME/.cache/repo/dijitso-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/dijitso.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases zesty artful bionic \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
