#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/matplotlib/matplotlib.git" \
  "$ORIG_DIR"

cd "$ORIG_DIR"
UPSTREAM_VERSION=$(python -c "import versioneer; print(versioneer.get_version())" | sed 's/+.*$//')

DEBIAN_DIR="$TMP_DIR/debian"
clone \
  --subdirectory=debian/ \
  "https://anonscm.debian.org/git/python-modules/packages/matplotlib.git" \
  "$DEBIAN_DIR"

# add colorspacious to dependencies
sed -i "s/python3-all-dev,/python3-all-dev, python-colorspacious, python3-colorspacious, python-functools32,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/matplotlib-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
