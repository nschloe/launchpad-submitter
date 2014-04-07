#!/bin/sh

THIS_DIR=`dirname $0`

$THIS_DIR/launchpad-submitter \
  --name netcdfcxx \
  --resubmission 1 \
  --git-dir "$HOME/software/netcdf-cxx/source/" \
  --ubuntu-releases precise quantal saucy trusty \
  --ppas nschloe/netcdf-nightly \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^\[]*\[[^]]*\][^\[]*\[\([^]]*\)\].*/\1/"' \
  --slot 1 \
  --submit
