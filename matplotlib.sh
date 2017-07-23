#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/matplotlib"
git -C "$CACHE" pull || git clone "https://github.com/matplotlib/matplotlib.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

cd "$ORIG_DIR"
UPSTREAM_VERSION=$(python -c "import versioneer; print(versioneer.get_version())" | sed 's/+.*$//')
# convert 2.0.0rc1 to 2.0.0~rc1 to fit with Debian versioning
UPSTREAM_VERSION=$(sanitize-debian-version "$UPSTREAM_VERSION")

# clean up versioneer.pyc
git clean -f -x -d

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/matplotlib-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/python-modules/packages/matplotlib.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# add colorspacious to dependencies
sed -i "s/python3-all-dev,/python3-all-dev, python-colorspacious, python3-colorspacious, python-functools32,/g" "$DEBIAN_DIR/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful \
  --version-override "$UPSTREAM_VERSION+git$(date +"%Y%m%d%H%M")" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/matplotlib-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
