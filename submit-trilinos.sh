#!/bin/sh

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name trilinos \
  --resubmission 1 \
  --git-dir "$HOME/software/trilinos/dev/github/" \
  --ubuntu-releases precise quantal saucy trusty \
  --ppas nschloe/trilinos-nightly \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --patches-dir patches-trilinos \
  --submit
