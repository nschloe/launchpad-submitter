#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/matplotlib/matplotlib.git" "$ORIG_DIR"

cd "$ORIG_DIR"
UPSTREAM_VERSION=$(python -c "import versioneer; print(versioneer.get_version())" | sed 's/+.*$//')

DEBIAN_DIR=$(mktemp -d)
clone \
   "https://anonscm.debian.org/git/python-modules/packages/matplotlib.git" \
   "$DEBIAN_DIR"

# add colorspacious to dependencies
sed -i "s/python3-all-dev,/python3-all-dev, python-colorspacious, python3-colorspacious, python-functools32,/g" "$DEBIAN_DIR/debian/control"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/matplotlib-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
