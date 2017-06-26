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
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$ORIG_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
# FULL_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d")"
FULL_UPSTREAM_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d%H%M")"

CACHE="$HOME/.cache/repo/dolfin-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/dolfin.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# vtk7
sed -i 's/libvtk6/libvtk7/g' "$ORIG_DIR/debian/control"

DEBIAN_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9]\).*/\1/')
sed -i "s/libdolfin$DEBIAN_VERSION/libdolfin$MAJOR.$MINOR/g" "$ORIG_DIR/debian/control"

# adapt dependencies:
#
#   python-ffc (>= 2016.2.0), python-ffc (<< 2016.3.0),
#
# becomes
#
#   python-ffc (>= 2017.2.0~), python-ffc (<< 2017.2.0),
#
SPLIT=(${DEBIAN_VERSION//./ })
DEBIAN_NEXT_VERSION="${SPLIT[0]}.$((SPLIT[1] + 1))"
NEXT_VERSION="$MAJOR.$((MINOR + 1))"
sed -i "s/$DEBIAN_NEXT_VERSION/$NEXT_VERSION/g" "$ORIG_DIR/debian/control"
#
DEBIAN_FULL_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9].[0-9]\).*/\1/')
sed -i "s/$DEBIAN_FULL_VERSION/$MAJOR.$MINOR.$MICRO~/g" "$ORIG_DIR/debian/control"

cd "$ORIG_DIR/debian"
rename "s/$DEBIAN_VERSION/$MAJOR.$MINOR/" ./*
mv python-dolfin.install python3-dolfin.install

# No xenial:
# Missing build dependencies: python-slepc4py
#  --ubuntu-releases yakkety zesty artful \
launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases zesty artful \
  --version-override "$FULL_UPSTREAM_VERSION" \
  --version-append-hash \
  --launchpad-login nschloe \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
