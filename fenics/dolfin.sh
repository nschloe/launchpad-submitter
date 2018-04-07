#!/bin/bash -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/dolfin"
git -C "$CACHE" pull || git clone "https://bitbucket.org/fenics-project/dolfin.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
UPSTREAM_VERSION=$(grep 'VERSION =' "$ORIG_DIR/python/setup.py" | sed 's/VERSION = "\(.*\)"/\1/g')
FULL_VERSION="$UPSTREAM_VERSION-git$(date +"%Y%m%d%H%M")"

# CACHE="$HOME/.cache/repo/dolfin-debian"
# git -C "$CACHE" pull || git clone "https://salsa.debian.org/science-team/fenics/dolfin.git" "$CACHE"
# rsync -a "$CACHE/debian" "$ORIG_DIR"
rsync -a "$HOME/rcs/debian/fenics/dolfin/debian" "$ORIG_DIR"

DEBIAN_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9]\).*/\1/')
sed -i "s/libdolfin$DEBIAN_VERSION/libdolfin$MAJOR.$MINOR/g" "$ORIG_DIR/debian/control"

# Untie the dependencies from the exact version
sed -i "s/python3-ffc.*/python3-ffc,/g" "$ORIG_DIR/debian/control"
sed -i "s/python3-dijitso.*/python3-dijitso,/g" "$ORIG_DIR/debian/control"

# # adapt dependencies:
# #
# #   python-ffc (>= 2016.2.0), python-ffc (<< 2016.3.0),
# #
# # becomes
# #
# #   python-ffc (>= 2017.2.0~), python-ffc (<< 2017.2.0),
# #
# SPLIT=(${DEBIAN_VERSION//./ })
# DEBIAN_NEXT_VERSION="${SPLIT[0]}.$((SPLIT[1] + 1))"
# NEXT_VERSION="$MAJOR.$((MINOR + 1))"
# sed -i "s/$DEBIAN_NEXT_VERSION/$NEXT_VERSION/g" "$ORIG_DIR/debian/control"
# #
# DEBIAN_FULL_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9].[0-9]\).*/\1/')
# sed -i "s/$DEBIAN_FULL_VERSION/$MAJOR.$MINOR.$MICRO~/g" "$ORIG_DIR/debian/control"
# #
# sed -i "s/\${source:Upstream-Version}/$MAJOR.$MINOR.$MICRO~/g" "$ORIG_DIR/debian/control"
# sed -i "s/\${source:Next-Upstream-Version}/$NEXT_VERSION/g" "$ORIG_DIR/debian/control"

cd "$ORIG_DIR/debian"
rename "s/$DEBIAN_VERSION/$MAJOR.$MINOR/" ./*

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases bionic \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
