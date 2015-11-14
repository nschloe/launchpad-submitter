#!/bin/sh -ue

# Set SSH agent variables.
eval "$(cat "$HOME/.ssh/agent/info")"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/vtk/pristine/"

# get version
MAJOR=$(grep VTK_MAJOR_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
MINOR=$(grep VTK_MINOR_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
PATCH=$(grep VTK_BUILD_VERSION "$SOURCE_DIR/CMake/vtkVersion.cmake" | sed 's/^.*\([0-9]\).*/\1/')
VERSION="$MAJOR.$MINOR.$PATCH"

"$THIS_DIR/launchpad-submitter" \
  --name vtk6 \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$HOME/rcs/debian-packages/vtk/upstream/debian/" \
  --debian-prepare "find . -type f -print0 | xargs -0 sed -i 's/6\.2\.0/$VERSION/g'" \
  --ubuntu-releases wily xenial \
  --version "$VERSION" \
  --patches-blacklist \
    10_allpatches.patch \
    30_matplotlib.patch \
    40_use_system_sqlite.patch \
    50_use_system_utf8.patch \
  --ppas nschloe/vtk-nightly \
  --submit-hashes-file "$THIS_DIR/vtk-submit-hashes.dat" \
  "$@"
