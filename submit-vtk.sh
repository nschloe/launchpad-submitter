#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# SOURCE_DIR="$HOME/software/vtk/pristine/"
SOURCE_DIR="$HOME/software/vtk/source-nschloe/"

# get version
MAJOR=$(grep VTK_MAJOR_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')

# Create a day-to-day version number of the form 4.3.1.2~201211230030.
# For launchpad to accept new submissions, the string has to increment.
VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"

DEBIAN_PREPARE="
find . -type f -print0 | xargs -0 sed -i 's/6\.3\.0+dfsg1-[0-9]/$VERSION/g'; \
find . -type f -print0 | xargs -0 sed -i 's/6\.3/$MAJOR.$MINOR/g'; \
sed -i \"/vtkMarchingCubesCases.h/d\" libvtk6-dev.install; \
sed -i \"/FTGL.h/d\" libvtk6-dev.install; \
sed -i \"/vtkftglConfig.h/d\" libvtk6-dev.install; \
sed -i \"/vtk_netcdf.h/d\" libvtk6-dev.install; \
sed -i \"/vtk_netcdfcpp.h/d\" libvtk6-dev.install; \
sed -i \"/10_allpatches.patch/d\" patches/series; \
sed -i \"/30_matplotlib.patch/d\" patches/series; \
sed -i \"/40_use_system_sqlite.patch/d\" patches/series; \
sed -i \"/50_use_system_utf8.patch/d\" patches/series; \
sed -i \"/90_gdal-2.0.patch/d\" patches/series; \
sed -i \"/97_fix_latex_doxygen.patch/d\" patches/series; \
sed -i \"/99_remove_xdmf3.patch/d\" patches/series; \
sed -i \"/102_enable_system_proj4_lib.patch/d\" patches/series; \
sed -i \"/104_fix_gcc_version_6.patch/d\" patches/series; \
sed -i \"/-DVTK_USE_SYSTEM_GL2PS=ON/d\" rules; \
sed -i \"/-DVTK_USE_SYSTEM_GLEW=ON/d\" rules; \
sed -i \"/-DVTK_USE_SYSTEM_LIBPROJ4=ON/d\" rules; \
sed -i \"/vtk_netcdfcpp.h/d\" rules; \
rename 's/6\.3/$MAJOR.$MINOR/' *; \
"

EXTRA_PREPARE="
sed -i \"/libnetcdf-cxx-legacy-dev/d\" control; \
"

VERSION="$MAJOR.$MINOR.$PATCH~$(date +"%Y%m%d%H%M%S")"
"$THIS_DIR/launchpad-submitter" \
  --name vtk6 \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/vtk/upstream/debian/" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases wily xenial \
  --version "$VERSION" \
  --ppas nschloe/vtk-nightly \
  --submit-hashes-file "$THIS_DIR/vtk-submit-hashes1.dat" \
  "$@"
