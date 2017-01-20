#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
# Can't --ignore-hidden here -- we need the .git directory for versioneer
clone \
  "https://github.com/matplotlib/matplotlib.git" \
  "$ORIG_DIR"

cd "$ORIG_DIR"
UPSTREAM_VERSION=$(python -c "import versioneer; print(versioneer.get_version())" | sed 's/+.*$//')
# clean up versioneer.pyc
git clean -f -x -d

DEBIAN_DIR="$TMP_DIR/orig/debian"
clone \
  --subdirectory=debian/ \
  "https://anonscm.debian.org/git/python-modules/packages/matplotlib.git" \
  "$DEBIAN_DIR"

# add colorspacious to dependencies
sed -i "s/python3-all-dev,/python3-all-dev, python-colorspacious, python3-colorspacious, python-functools32,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/matplotlib-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"