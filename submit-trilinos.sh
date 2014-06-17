#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/dev/github/" \
  --debian-dir "$HOME/rcs/debian-trilinos/debian/" \
  --ubuntu-releases trusty utopic \
  --ppas nschloe/trilinos-nightly \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --extra-patches-dir patches-trilinos \
  --submit
  #--ubuntu-releases precise saucy trusty \
