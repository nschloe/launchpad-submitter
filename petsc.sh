#!/bin/sh -ue

# Set SSH agent variables.
. "$HOME/.keychain/$(/bin/hostname)-sh"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

DIR=$(mktemp -d)
"$HOME/rcs/launchpad-tools/create-debian-repo" \
   --orig "git@bitbucket.org:petsc/petsc.git" \
   --debian "git://anonscm.debian.org/git/debian-science/packages/petsc.git" \
   --out "$DIR"

echo "$DIR"

VERSION_MAJOR=$(grep '#define PETSC_VERSION_MAJOR' "$DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_MINOR=$(grep '#define PETSC_VERSION_MINOR' "$DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_SUBMINOR=$(grep '#define PETSC_VERSION_SUBMINOR' "$DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)

# PETSc adds a 0 to the minor version for development to distinguish it from
# the release.
UPSTREAM_SOVERSION=$VERSION_MAJOR.0$VERSION_MINOR
UPSTREAM_VERSION=$VERSION_MAJOR.0$VERSION_MINOR.$VERSION_SUBMINOR

DEBIAN_VERSION=$(head -n 1 "$DIR/debian/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_SOVERSION=$(head -n 1 "$DIR/debian/changelog" | sed 's/[^0-9]*\([0-9]\.[0-9]\).*/\1/')

# Some comments here:
#   * We cannot enable sowing since it requires downloading the software at
#     configure time which isn't possible on launchpad.
#   * No sowing => no fortran interface (Matt Knepley, Apr 2016).
#   * SuperLU is outdated in Debian.
sed -i "/build-no-rpath.patch/d" "$DIR/debian/patches/series"
sed -i "/docs.patch/d" "$DIR/debian/patches/series"
sed -i "/example-src-dir.patch/d" "$DIR/debian/patches/series"
sed -i "/with-fortran-interfaces/d" "$DIR/debian/rules"
sed -i "/--with-superlu=1/d" "$DIR/debian/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/\*html/d" "$DIR/debian/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/petsc\/\*\/\*html/d" "$DIR/debian/rules"
sed -i "s/--useThreads 0/--useThreads=0 --with-sowing=0/g" "$DIR/debian/rules"
sed -i "/makefile.html/d" "$DIR/debian/petsc$DEBIAN_VERSION-doc.docs"
sed -i "/docs/d" "$DIR/debian/petsc$DEBIAN_VERSION-doc.docs"
cd "$DIR/debian"
rename "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/" ./*
git add ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_SOVERSION/$UPSTREAM_SOVERSION/g" "$i"
done
cd "$DIR" && git commit -a -m "update debian"

"$HOME/rcs/launchpad-tools/launchpad-submit" \
  --directory "$DIR" \
  --ubuntu-releases wily xenial yakkety \
  --version "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --ppa nschloe/petsc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg" \
  --debfullname "Nico Schlömer" \
  --debemail "nico.schloemer@gmail.com" \
  "$@"
