#!/bin/sh

# Set SSH agent variables.
eval $(cat $HOME/.ssh/agent/info)

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name netcdfcxx \
  --resubmission 1 \
  --source-dir "$HOME/software/netcdf-cxx/source/" \
  --debian-dir "$HOME/rcs/debian-packages/netcdfcxx/" \
  --ubuntu-releases trusty utopic \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/"' \
  --ppas nschloe/netcdf-nightly
#  --slot 1 \
