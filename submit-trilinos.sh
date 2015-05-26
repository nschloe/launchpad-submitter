#!/bin/sh -ue

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# use a different debian/ folder for precise
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$THIS_DIR/debian-trilinos-precise/" \
  --ubuntu-releases precise \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos0-submit-hashes.dat"

# submit for the rest
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$HOME/rcs/debian-packages/trilinos/debian/" \
  --ubuntu-releases trusty utopic vivid wily \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos1-submit-hashes.dat"
