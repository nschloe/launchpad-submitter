# Source the function submitter.
. ./launchpad-submitter.sh

get_version(){
  echo `grep "^AC_INIT" configure.ac | sed 's/[^0-9]*\([0-9][\.0-9]*\).*/\1/'`
  return 0
}
declare -a UBUNTU_RELEASES=(trusty)
declare -a PPAS=(nschloe/netcdf-nightly)
submit \
  'netcdfcxx' \
  1 \
  "$HOME/software/netcdf-cxx/source/" \
  "./debian-cxx/" \
  $UBUNTU_RELEASES \
  $PPAS \
  get_version
