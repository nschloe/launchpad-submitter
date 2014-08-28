#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name netcdff \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-fortran/source/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdff/" \
  --ubuntu-releases trusty utopic \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/netcdf-nightly
