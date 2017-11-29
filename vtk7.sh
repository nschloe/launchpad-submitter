#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/vtk"
git -C "$CACHE" pull || git clone --recursive "https://github.com/Kitware/VTK.git" "$CACHE"
cd "$CACHE" && git submodule update --init --recursive
# Don't use local `git clone --shared` here since that doesn't consider the
# submodules.
rsync -a "$CACHE/" "$ORIG_DIR"

MAJOR=$(grep VTK_MAJOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH+git$(date +"%Y%m%d%H%M")"
# VERSION="$MAJOR.$MINOR.$PATCH+git$(date +"%Y%m%d")"

CACHE="$HOME/.cache/repo/vtk7-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/vtk7.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

# get debian version
DEBIAN_VERSION=$(head -n 1 "$ORIG_DIR/debian/changelog" | sed 's/vtk7 (\([0-9].[0-9].[0-9]\).*/\1/g')
DEBIAN_MAJOR=$(echo "$DEBIAN_VERSION" | sed 's/\([0-9]\).*/\1/g')
DEBIAN_MINOR=$(echo "$DEBIAN_VERSION" | sed 's/[0-9].\([0-9]\).*/\1/g')

# add missing dependencies
sed -i "s/Build-Depends:/Build-Depends: libqt5x11extras5-dev,/" "$ORIG_DIR/debian/control"
# don't use system libproj4 yet
sed -i "s/-DVTK_USE_SYSTEM_LIBPROJ4=ON/-DVTK_USE_SYSTEM_LIBPROJ4=OFF/" "$ORIG_DIR/debian/rules"
# don't use system gl2ps
sed -i "s/-DVTK_USE_SYSTEM_GL2PS=ON/-DVTK_USE_SYSTEM_GL2PS=OFF/" "$ORIG_DIR/debian/rules"
# don't use system utf8
sed -i "/50_use_system_utf8.patch/d" "$ORIG_DIR/debian/patches/series"

#
sed -i "s/vtk-$DEBIAN_MAJOR.$DEBIAN_MINOR/vtk-$MAJOR.$MINOR/" "$ORIG_DIR/debian/rules"
sed -i "s/vtk-$DEBIAN_MAJOR.$DEBIAN_MINOR/vtk-$MAJOR.$MINOR/" "$ORIG_DIR/debian/libvtk$DEBIAN_MAJOR-dev.install"
sed -i "/vtk_netcdfcpp.h/d" "$ORIG_DIR/debian/rules"
sed -i "/vtk_netcdfcpp.h/d" "$ORIG_DIR/debian/libvtk$DEBIAN_MAJOR-dev.install"


launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases artful bionic \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/vtk7-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
