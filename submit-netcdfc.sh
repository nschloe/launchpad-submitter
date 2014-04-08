#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name netcdfc \
  --resubmission 1 \
  --git-dir "$HOME/software/netcdf-c/dev/source/" \
  --ubuntu-releases precise quantal saucy trusty \
  --ppas nschloe/netcdf-nightly nschloe/trilinos-nightly \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --slot 1 \
  --submit
