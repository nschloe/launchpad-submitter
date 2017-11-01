#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/vtk"
git -C "$CACHE" pull || git clone "https://github.com/Kitware/VTK.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

MAJOR=$(grep VTK_MAJOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH+git$(date +"%Y%m%d%H%M")"
# VERSION="$MAJOR.$MINOR.$PATCH+git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/vtk7-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/vtk7.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# # add missing dependencies
# sed -i "s/Build-Depends:/Build-Depends: libqt5x11extras5-dev,/" "$ORIG_DIR/debian/control"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful bionic \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/vtk7-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
