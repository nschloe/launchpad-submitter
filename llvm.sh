#!/bin/sh -ue

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

ORIG_DIR=$(mktemp -d)
clone "https://github.com/llvm-mirror/llvm.git" "$ORIG_DIR"

clone "https://github.com/llvm-mirror/clang.git" "$ORIG_DIR/clang"
ln -s "$ORIG_DIR/clang" "$ORIG_DIR/tools/"

clone "https://github.com/llvm-mirror/clang-tools-extra.git" "$ORIG_DIR/clang-tools-extra"
ln -s "$ORIG_DIR/clang-tools-extra" "$ORIG_DIR/tools/clang/tools/extra"

clone "https://github.com/llvm-mirror/polly.git" "$ORIG_DIR/polly"
ln -s "$ORIG_DIR/polly" "$ORIG_DIR/tools/"

clone "https://github.com/llvm-mirror/lld.git" "$ORIG_DIR/lld"
ln -s "$ORIG_DIR/lld" "$ORIG_DIR/tools/"

clone "https://github.com/llvm-mirror/lldb.git" "$ORIG_DIR/lldb"
ln -s "$ORIG_DIR/lldb" "$ORIG_DIR/tools/"

MAJOR=$(grep 'set(LLVM_VERSION_MAJOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
MINOR=$(grep 'set(LLVM_VERSION_MINOR ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
PATCH=$(grep 'set(LLVM_VERSION_PATCH ' "$ORIG_DIR/CMakeLists.txt" | sed 's/^[^0-9]*\([0-9]*\).*/\1/')
UPSTREAM_VERSION="$MAJOR.$MINOR.$PATCH"

DEBIAN_DIR=$(mktemp -d)
clone "svn://anonscm.debian.org/svn/pkg-llvm/llvm-toolchain/branches/snapshot/" "$DEBIAN_DIR"

sed -i "/asan_symbolize.py/d" "$DEBIAN_DIR/debian/rules"

launchpad-submit \
  --orig "$ORIG_DIR" \
  --debian "$DEBIAN_DIR/debian" \
  --update-patches \
  --ubuntu-releases trusty xenial yakkety zesty \
  --version-override "$UPSTREAM_VERSION~$(date +"%Y%m%d%H%M%S")" \
  --version-append-hash \
  --ppa nschloe/llvm-nightly \
  --debuild-params="-p$THIS_DIR/mygpg"

rm -rf "$ORIG_DIR" "$DEBIAN_DIR"
