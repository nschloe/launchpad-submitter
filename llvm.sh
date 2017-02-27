#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ORIG_DIR="$TMP_DIR/orig"
CACHE="$HOME/.cache/repo/llvm"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/llvm.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR"

CACHE="$HOME/.cache/repo/clang"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/clang.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR/clang"
ln -s "$ORIG_DIR/clang" "$ORIG_DIR/tools/"

CACHE="$HOME/.cache/repo/clang-tools-extra"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/clang-tools-extra.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR/clang-tools-extra"
ln -s "$ORIG_DIR/clang-tools-extra" "$ORIG_DIR/tools/clang/tools/extra"

CACHE="$HOME/.cache/repo/polly"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/polly.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR/polly"
ln -s "$ORIG_DIR/polly" "$ORIG_DIR/tools/"

CACHE="$HOME/.cache/repo/lld"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/lld.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR/lld"
ln -s "$ORIG_DIR/lld" "$ORIG_DIR/tools/"

CACHE="$HOME/.cache/repo/lldb"
git -C "$CACHE" pull || git clone "https://github.com/llvm-mirror/lldb.git" "$CACHE"
git clone --shared "$CACHE" "$ORIG_DIR/lldb"
ln -s "$ORIG_DIR/lldb" "$ORIG_DIR/tools/"

MAJOR=$(grep 'set(LLVM_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(LLVM_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(LLVM_VERSION_PATCH ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR="$ORIG_DIR/debian"
CACHE="$HOME/.cache/repo/llvm-debian"
(cd "$CACHE" && svn up) || svn co "svn://anonscm.debian.org/svn/pkg-llvm/llvm-toolchain/branches/snapshot/" "$CACHE"
rsync -a "$CACHE/debian" "$ORIG_DIR"

sed -i "/asan_symbolize.py/d" "$DEBIAN_DIR/rules"

launchpad-submit \
  --work-dir "$TMP_DIR" \
  --update-patches \
  --ubuntu-releases xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~git$(date +"%Y%m%d")" \
  --version-append-hash \
  --ppa nschloe/llvm-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"
