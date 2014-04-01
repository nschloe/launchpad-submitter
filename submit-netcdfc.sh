# Source the function submitter.
. ./launchpad-submitter.sh

# From the line
# '''
# AC_INIT([netCDF], [4.3.1.2], [support-netcdf@unidata.ucar.edu])
# '''
# extract "4.3.1.2".
get_version(){
  echo `grep "^AC_INIT" configure.ac | sed 's/[^0-9]*\([0-9][\.0-9]*\).*/\1/'`
  return 0
}

declare -a UBUNTU_RELEASES=(precise quantal saucy trusty)
declare -a PPAS=(nschloe/netcdf-nightly nschloe/trilinos-nightly)

submit \
  'netcdfc' \
  1 \
  "$HOME/software/netcdf-c/dev/source/" \
  "./debian-c/" \
  $UBUNTU_RELEASES \
  $PPAS \
  get_version
