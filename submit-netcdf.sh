#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name netcdf \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-c/dev/source/" \
  --debian-dir "$HOME/rcs/debian-netcdf-official/debian/" \
  --ubuntu-releases precise quantal saucy trusty utopic \
  --ppas nschloe/netcdf-nightly nschloe/trilinos-nightly \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --slot 1 \
  --submit
