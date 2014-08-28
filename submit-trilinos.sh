#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# submit for trusty, utopic
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$HOME/rcs/debian-packages/trilinos/debian/" \
  --ubuntu-releases trusty utopic \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly

# use a different debian/ folder for precise
$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$THIS_DIR/debian-trilinos-precise/" \
  --ubuntu-releases precise \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly
