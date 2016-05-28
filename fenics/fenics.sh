#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get version from Dolfin
DOLFIN_DIR=$(mktemp -d)
clone "https://nschloe@bitbucket.org/fenics-project/dolfin.git" "$DOLFIN_DIR"
MAJOR=$(grep 'DOLFIN_VERSION_MAJOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MINOR=$(grep 'DOLFIN_VERSION_MINOR ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
MICRO=$(grep 'DOLFIN_VERSION_MICRO ' "$DOLFIN_DIR/CMakeLists.txt" | sed 's/.*\([0-9]\).*/\1/')
FULL_VERSION="$MAJOR.$MINOR.$MICRO~$(date +"%Y%m%d%H%M%S")"
rm -rf "$DOLFIN_DIR"

launchpad-submit \
  --orig "git://anonscm.debian.org/git/debian-science/packages/fenics/fenics.git" \
  --version-override "$FULL_VERSION" \
  --version-append-hash \
  --ppa nschloe/fenics-nightly \
  --ubuntu-releases trusty wily xenial yakkety \
  --debuild-params="-p$THIS_DIR/../mygpg"
