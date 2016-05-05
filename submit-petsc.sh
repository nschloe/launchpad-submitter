#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/petsc/source-upstream/"
cd "$SOURCE_DIR" && git pull

VERSION_MAJOR=$(grep '#define PETSC_VERSION_MAJOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_MINOR=$(grep '#define PETSC_VERSION_MINOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_SUBMINOR=$(grep '#define PETSC_VERSION_SUBMINOR' "$SOURCE_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)

# PETSc adds a 0 to the minor version for development to distinguish it from
# the release.
UPSTREAM_SOVERSION=$VERSION_MAJOR.0$VERSION_MINOR
UPSTREAM_VERSION=$VERSION_MAJOR.0$VERSION_MINOR.$VERSION_SUBMINOR

DEBIAN_DIR="$HOME/rcs/debian-packages/petsc/debian/"
cd "$DEBIAN_DIR" && git pull

DEBIAN_VERSION=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_SOVERSION=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9]\.[0-9]\).*/\1/')

# Some comments here:
#   * We cannot enable sowing since it requires downloading the software at
#     configure time which isn't possible on launchpad.
#   * No sowing, no fortran interface (Matt Knepley, Apr 2016).
#   * SuperLU is outdated in Debian.
cd "$DEBIAN_DIR"
sed -i "/build-no-rpath.patch/d" patches/series
sed -i "/docs.patch/d" patches/series
sed -i "/example-src-dir.patch/d" patches/series
sed -i "/hypre.patch/d" patches/series
sed -i "/soname_extension/d" patches/series
sed -i "/install_python_RDict_upstream_5a4feeed41cb1af9234d439bb06ea004d3cfa5c6/d" patches/series
sed -i "/with-fortran-interfaces/d" rules
sed -i "/--with-superlu=1/d" rules
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/\*html/d" rules
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/petsc\/\*\/\*html/d" rules
sed -i "s/--useThreads 0/--useThreads=0 --with-sowing=0/g" rules
sed -i "/makefile.html/d" "petsc$DEBIAN_VERSION-doc.docs"
sed -i "/docs/d" "petsc$DEBIAN_VERSION-doc.docs"
rename "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_SOVERSION/$UPSTREAM_SOVERSION/g" "$i"
done

DIR="/tmp/petsc"
rm -rf "$DIR"
"$THIS_DIR/create-debian-repo" \
  --source "$SOURCE_DIR" \
  --debian "$DEBIAN_DIR" \
  --out "$DIR"

cd "$DEBIAN_DIR" && git checkout . && git clean -f -d -x

"$THIS_DIR/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --ppa nschloe/petsc-nightly \
  "$@"
