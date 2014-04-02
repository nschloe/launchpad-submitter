#!/bin/sh

./launchpad-submitter \
  --name netcdff \
  --resubmission 1 \
  --git-dir "$HOME/software/netcdf-fortran/source/" \
  --ubuntu-releases precise quantal saucy trusty \
  --ppas nschloe/netcdf-nightly \
  --version-getter 'grep "^AC_INIT" configure.ac | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --submit
