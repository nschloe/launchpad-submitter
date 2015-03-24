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
  --patches-blacklist stk-sizet.patch \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos0-submit-hashes.dat" \
  --force

# submit for trusty, utopic
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$THIS_DIR/debian-trilinos-trusty/" \
  --ubuntu-releases trusty utopic \
  --patches-blacklist stk-sizet.patch \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos1-submit-hashes.dat" \
  --force

# submit for vivid
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$HOME/rcs/debian-packages/trilinos/debian/" \
  --ubuntu-releases vivid \
  --patches-blacklist stk-sizet.patch \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos2-submit-hashes.dat" \
  --force
