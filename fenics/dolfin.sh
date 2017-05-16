#!/bin/sh -ue

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
FULL_VERSION="$MAJOR.$MINOR.$MICRO~git$(date +"%Y%m%d%H%M")"

CACHE="$HOME/.cache/repo/dolfin-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/fenics/dolfin.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# remove overly strict conditions
sed -i 's/python3-ffc (<< 2016.3.0),//g' "$ORIG_DIR/debian/control"
sed -i 's/python3-dijitso (<< 2016.3.0),//g' "$ORIG_DIR/debian/control"

# vtk7
sed -i 's/libvtk6/libvtk7/g' "$ORIG_DIR/debian/control"

sed -i 's/python3-ffc (>= ${source:Upstream-Version}), python3-ffc (<< ${source:Next-Upstream-Version})/python3-ffc/g' "$ORIG_DIR/debian/control"
sed -i 's/python3-dijitso (>= ${source:Upstream-Version}), python3-dijitso (<< ${source:Next-Upstream-Version})/python3-dijitso/g' "$ORIG_DIR/debian/control"
sed -i 's/python3-instant (>= ${source:Upstream-Version}), python3-instant (<< ${source:Next-Upstream-Version})/python3-instant/g' "$ORIG_DIR/debian/control"
sed -i 's/python3-ufl (>= ${source:Upstream-Version}), python3-ufl (<< ${source:Next-Upstream-Version})/python3-ufl/g' "$ORIG_DIR/debian/control"

# sed -i 's/python-dev,/python-dev, python3-dev, python3, python3-minimal,/g' "$ORIG_DIR/debian/control"
# sed -i 's/--with python2/--with python3/g' "$ORIG_DIR/debian/rules"
# sed -i 's/-D CMAKE_SKIP_RPATH:BOOL=ON/-D CMAKE_SKIP_RPATH:BOOL=ON -DDOLFIN_USE_PYTHON3:BOOL=OFF/g' "$ORIG_DIR/debian/rules"

DEBIAN_VERSION=$(head -n1 "$ORIG_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]*\.[0-9]\).*/\1/')
sed -i "s/libdolfin$DEBIAN_VERSION/libdolfin$MAJOR.$MINOR/g" "$ORIG_DIR/debian/control"

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
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --debuild-params="-p$THIS_DIR/../mygpg"
