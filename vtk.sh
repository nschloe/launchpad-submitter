#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
clone --ignore-hidden \
  "https://github.com/Kitware/VTK.git" \
  "$ORIG_DIR"

MAJOR=$(grep VTK_MAJOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$ORIG_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
# Create a day-to-day version number of the form 4.3.1.2~201211230030.
# For launchpad to accept new submissions, the string has to increment.
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_DIR="$TMP_DIR/debian"
clone --ignore-hidden \
  "git://anonscm.debian.org/debian-science/packages/vtk6.git" \
  "$DEBIAN_DIR"

# Replace version everywhere except the changelog
cp "$DEBIAN_DIR/debian/changelog" "/tmp/changelog"
find "$DEBIAN_DIR/debian" -type f -print0 | xargs -0 sed -i "s/6\.3\.0+dfsg1-[0-9]/$VERSION/g"
find "$DEBIAN_DIR/debian" -type f -print0 | xargs -0 sed -i "s/6\.3/$MAJOR.$MINOR/g"
rm -f "$DEBIAN_DIR/debian/changelog" && cp "/tmp/changelog" "$DEBIAN_DIR/debian/changelog"
#
sed -i "/vtkMarchingCubesCases.h/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/exportheader.cmake.in/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/FTGL.h/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/50_use_system_utf8.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/vtkftglConfig.h/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/vtk_netcdf.h/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/vtk_netcdfcpp.h/d" "$DEBIAN_DIR/debian/libvtk6-dev.install"
sed -i "/-DVTK_USE_SYSTEM_GL2PS=ON/d" "$DEBIAN_DIR/debian/rules"
sed -i "/-DVTK_USE_SYSTEM_GLEW=ON/d" "$DEBIAN_DIR/debian/rules"
sed -i "/-DVTK_USE_SYSTEM_LIBPROJ4=ON/d" "$DEBIAN_DIR/debian/rules"
sed -i "/vtk_netcdfcpp.h/d" "$DEBIAN_DIR/debian/rules"
sed -i "s/libqt5webkit5-dev,/libqt5webkit5-dev, libqt5x11extras5-dev,/g" "$DEBIAN_DIR/debian/control"
cd "$DEBIAN_DIR/debian" && rename "s/6\.3/$MAJOR.$MINOR/" ./*

launchpad-submit \
  --orig-dir "$ORIG_DIR" \
  --debian-dir "$DEBIAN_DIR/debian" \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$VERSION" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/vtk-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
