#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/petsc"
git -C "$CACHE" pull || git clone "https://bitbucket.org/petsc/petsc.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

VERSION_MAJOR=$(grep '#define PETSC_VERSION_MAJOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_MINOR=$(grep '#define PETSC_VERSION_MINOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)
VERSION_SUBMINOR=$(grep '#define PETSC_VERSION_SUBMINOR' "$ORIG_DIR/include/petscversion.h" | sed 's/[^0-9]*//' -)

# Note:
# PETSc adds a 0 to the minor version for development to distinguish it from
# the release. Don't do that here; we append +git<date>.
UPSTREAM_SOVERSION=$VERSION_MAJOR.$VERSION_MINOR
UPSTREAM_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_SUBMINOR

DEBIAN_DIR="$TMP_DIR/orig/debian"
CACHE="$HOME/.cache/repo/petsc-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/petsc.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

DEBIAN_VERSION=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9\.]*[0-9]\).*/\1/')
DEBIAN_SOVERSION=$(head -n 1 "$DEBIAN_DIR/changelog" | sed 's/[^0-9]*\([0-9]\.[0-9]\).*/\1/')

# Some comments here:
#   * We cannot enable sowing since it requires downloading the software at
#     configure time which isn't possible on launchpad.
#   * No sowing => no fortran interface (Matt Knepley, Apr 2016).
#   * SuperLU is outdated in Debian.
sed -i "/with-fortran-interfaces/d" "$DEBIAN_DIR/rules"
sed -i "/--with-superlu=1/d" "$DEBIAN_DIR/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/\*html/d" "$DEBIAN_DIR/rules"
sed -i "/\$(PETSC_DIR_DEBUG_PREFIX)\/include\/petsc\/\*\/\*html/d" "$DEBIAN_DIR/rules"
sed -i "s/--useThreads 0/--useThreads=0 --with-sowing=0/g" "$DEBIAN_DIR/rules"
sed -i "/makefile.html/d" "$DEBIAN_DIR/petsc$DEBIAN_VERSION-doc.docs"
sed -i "/docs/d" "$DEBIAN_DIR/petsc$DEBIAN_VERSION-doc.docs"
cd "$DEBIAN_DIR/"
rename "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/" ./*
for i in ./*; do
  [ -f "$i" ] && sed -i "s/$DEBIAN_VERSION/$UPSTREAM_VERSION/g" "$i"
  [ -f "$i" ] && sed -i "s/$DEBIAN_SOVERSION/$UPSTREAM_SOVERSION/g" "$i"
done

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases zesty artful \
  --version-override "$UPSTREAM_VERSION+git$(date +"%Y%m%d")" \
  --version-append-hash \
  --update-patches \
  --ppa nschloe/petsc-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
