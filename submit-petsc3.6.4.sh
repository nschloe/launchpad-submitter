#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/petsc/petsc-3.6.4"

VERSION_MAJOR=$(grep '#define PETSC_VERSION_MAJOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_MINOR=$(grep '#define PETSC_VERSION_MINOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_SUBMINOR=$(grep '#define PETSC_VERSION_SUBMINOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)

UPSTREAM_VERSION="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_SUBMINOR"

# FULL_VERSION="3.0.8-$(date +"%Y%m%d%H%M%S")"
FULL_VERSION="$UPSTREAM_VERSION-ppa2"

DEBIAN_DIR="$HOME/rcs/debian-packages/petsc/debian/"
DEBIAN_VERSION=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')

DEBIAN_PREPARE="
sed -i \"s/hypre-2.10.0b-p2/hypre-2.10.0b-p4/\" patches/hypre.patch; \
sed -i \"/install_python_RDict_upstream_5a4feeed41cb1af9234d439bb06ea004d3cfa5c6/d\" patches/series; \
rename 's/$DEBIAN_VERSION/$UPSTREAM_VERSION/' *; \
for i in *; do sed -i 's/$DEBIAN_VERSION/$UPSTREAM_VERSION/g' \"\$i\"; done \
"
"$THIS_DIR/launchpad-submit" \
  --source-dir "$SOURCE_DIR" \
  --debian-dir "$DEBIAN_DIR" \
  --debian-prepare "$DEBIAN_PREPARE" \
  --ubuntu-releases trusty wily \
  --version "$FULL_VERSION" \
  --ppa nschloe/petsc-backports \
  --submit-hashes-file "$THIS_DIR/petsc-submit-hash.dat" \
  "$@"
