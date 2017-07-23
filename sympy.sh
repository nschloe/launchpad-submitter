#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/sympy"
git -C "$CACHE" pull || git clone "https://github.com/sympy/sympy.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

UPSTREAM_VERSION=$(sed 's/[^\"]*\"\([^\"]*\)\".*/\1/' "$ORIG_DIR/sympy/release.py")

CACHE="$HOME/.cache/repo/sympy-debian"
git -C "$CACHE" pull || git clone "https://anonscm.debian.org/git/debian-science/packages/sympy.git" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --ubuntu-releases xenial zesty artful \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d")" \
  --version-append-hash \
  --update-patches \
  --launchpad-login nschloe \
  --ppa nschloe/sympy-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
