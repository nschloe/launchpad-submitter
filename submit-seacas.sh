#!/bin/sh -ue

# Set SSH agent variables.
eval "$(cat "$HOME/.ssh/agent/info")"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

"$THIS_DIR/launchpad-submitter" \
  --name seacas \
  --resubmission 1 \
  --source-dir "$HOME/software/seacas/source-upstream/" \
  --ubuntu-releases trusty vivid wily xenial \
  --version-getter 'grep "SEACASProj_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/seacas-nightly \
  --submit-hashes-file "$THIS_DIR/seacas-submit-hash1.dat" \
  "$@"
