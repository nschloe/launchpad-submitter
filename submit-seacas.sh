#!/bin/sh -ue

# Set SSH agent variables.
eval "$(cat "$HOME/.ssh/agent/info")"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

SOURCE_DIR="$HOME/software/seacas/source-upstream/"
VERSION=$(grep "SEACASProj_VERSION " "$SOURCE_DIR/Version.cmake" | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/")

"$THIS_DIR/launchpad-submitter" \
  --name seacas \
  --source-dir "$SOURCE_DIR" \
  --ubuntu-releases trusty vivid wily xenial \
  --version "$VERSION" \
  --ppas nschloe/seacas-nightly \
  --submit-hashes-file "$THIS_DIR/seacas-submit-hash1.dat" \
  "$@"
