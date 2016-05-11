#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
"$HOME/rcs/launchpad-tools/create-debian-repo" \
  --source "git@github.com:Kitware/VTK.git" \
  --debian "git://anonscm.debian.org/debian-science/packages/vtk6.git" \
  --out "$DIR"

# get version
MAJOR=$(grep VTK_MAJOR_VERSION "$DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')

# Create a day-to-day version number of the form 4.3.1.2~201211230030.
# For launchpad to accept new submissions, the string has to increment.
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

find . -type f -print0 | xargs -0 sed -i "s/6\.3\.0+dfsg1-[0-9]/$VERSION/g"
find . -type f -print0 | xargs -0 sed -i "s/6\.3/$MAJOR.$MINOR/g"
sed -i "/vtkMarchingCubesCases.h/d" "$DIR/debian/libvtk6-dev.install"
sed -i "/FTGL.h/d" "$DIR/debian/libvtk6-dev.install"
sed -i "/vtkftglConfig.h/d" "$DIR/debian/libvtk6-dev.install"
sed -i "/vtk_netcdf.h/d" "$DIR/debian/libvtk6-dev.install"
sed -i "/vtk_netcdfcpp.h/d" "$DIR/debian/libvtk6-dev.install"
sed -i "/40_use_system_sqlite.patch/d" "$DIR/debian/patches/series"
sed -i "/90_gdal-2.0.patch/d" "$DIR/debian/patches/series"
sed -i "/95_ffmpeg_2.9.patch/d" "$DIR/debian/patches/series"
sed -i "/97_fix_latex_doxygen.patch/d" "$DIR/debian/patches/series"
sed -i "/102_enable_system_proj4_lib.patch/d" "$DIR/debian/patches/series"
sed -i "/104_fix_gcc_version_6.patch/d" "$DIR/debian/patches/series"
sed -i "/-DVTK_USE_SYSTEM_GL2PS=ON/d" "$DIR/debian/rules"
sed -i "/-DVTK_USE_SYSTEM_GLEW=ON/d" "$DIR/debian/rules"
sed -i "/-DVTK_USE_SYSTEM_LIBPROJ4=ON/d" "$DIR/debian/rules"
sed -i "/vtk_netcdfcpp.h/d" "$DIR/debian/rules"
rename "s/6\.3/$MAJOR.$MINOR/" ./*
cd "$DIR" && git commit -a -m "update debian"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$VERSION" \
  --ppa nschloe/vtk-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"
