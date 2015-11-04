#!/bin/sh -ue

# Set SSH agent variables.
eval "$(cat "$HOME/.ssh/agent/info")"

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# copy over debian dir and replace respective lines
rm -rf '/tmp/debian-trusty'
cp -r "$HOME/rcs/debian-packages/trilinos/debian/" "/tmp/debian-trusty"
# remove hdf5 support
sed -i '/libhdf5-openmpi-dev/d' '/tmp/debian-trusty/control'
sed -i '/HDF5/d' '/tmp/debian-trusty/rules'
# remove superlu support
sed -i '/libsuperlu-dev/d' '/tmp/debian-trusty/control'
sed -i '/SuperLU/d' '/tmp/debian-trusty/rules'

# trusty
"$THIS_DIR/launchpad-submitter" \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "/tmp/debian-trusty/" \
  --ubuntu-releases trusty \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos1-submit-hashes.dat" \
  "$@"

# Wait at least a minute to make sure that the below submission gets another
# timestamp. Otherwise, the upload will be rejected with
# ```
# Rejected:
# File moab_4.8.3pre~201510280949.orig.tar.gz already exists in MOAB nightly,
# but uploaded version has different contents.
# ```
sleep 60

# submit for the rest
"$THIS_DIR/launchpad-submitter" \
  --name trilinos \
  --resubmission 1 \
  --source-dir "$HOME/software/trilinos/github/" \
  --debian-dir "$HOME/rcs/debian-packages/trilinos/debian/" \
  --ubuntu-releases vivid wily xenial \
  --version-getter 'grep "Trilinos_VERSION " Version.cmake | sed "s/[^0-9]*\([0-9][\.0-9]*\).*/\1/"' \
  --ppas nschloe/trilinos-nightly \
  --submit-hashes-file "$THIS_DIR/trilinos2-submit-hashes.dat" \
  "$@"
