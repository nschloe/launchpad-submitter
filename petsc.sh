#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git@bitbucket.org:petsc/petsc.git" \
   "$ORIG_DIR"

VERSION_MAJOR=$(grep '#define PETSC_VERSION_MAJOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_MINOR=$(grep '#define PETSC_VERSION_MINOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_SUBMINOR=$(grep '#define PETSC_VERSION_SUBMINOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)

# PETSc adds a 0 to the minor version for development to distinguish it from
# the release.
UPSTREAM_SOVERSION=$VERSION_MAJOR.0$VERSION_MINOR
UPSTREAM_VERSION=$VERSION_MAJOR.0$VERSION_MINOR.$VERSION_SUBMINOR

DEBIAN_DIR=$(mktemp -d)
"$HOME/rcs/launchpadtools/tools/cloner" \
   "git://anonscm.debian.org/git/debian-science/packages/petsc.git" \
   "$DEBIAN_DIR"

DEBIAN_VERSION=$(head -n 1 "$DEBIAN_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_SOVERSION=$(head -n 1 "$DEBIAN_DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]\.[0-9]\).*/\1/')

# Some comments here:
#   * We cannot enable sowing since it requires downloading the software at
#     configure time which isn't possible on launchpad.
#   * No sowing => no fortran interface (Matt Knepley, Apr 2016).
#   * SuperLU is outdated in Debian.
sed -i "/build-no-rpath.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/docs.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/example-src-dir.patch/d" "$DEBIAN_DIR/debian/patches/series"
sed -i "/with-fortran-interfaces/d" "$DEBIAN_DIR/debian/rules"
sed -i "/--with-superlu=1/d" "$DEBIAN_DIR/debian/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/\*html/d" "$DEBIAN_DIR/debian/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/petsc\/\*\/\*html/d" "$DEBIAN_DIR/debian/rules"
sed -i "s/--useThreads 0/--useThreads=0 --with-sowing=0/g" "$DEBIAN_DIR/debian/rules"
sed -i "/makefile.html/d" "$DEBIAN_DIR/debian/petsc$DEBIAN_VERSION-doc.docs"
sed -i "/docs/d" "$DEBIAN_DIR/debian/petsc$DEBIAN_VERSION-doc.docs"
cd "$DEBIAN_DIR/debian"
rename "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_SOVERSION/$UPSTREAM_SOVERSION/g" "$i"
done

"$HOME/rcs/launchpadtools/tools/launchpad-submit" \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --ubuntu-releases wily xenial yakkety \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/petsc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"

rm -rf "$ORIG_DIR"
rm -rf "$DEBIAN_DIR"
