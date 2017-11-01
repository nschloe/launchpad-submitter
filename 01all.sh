#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# add ssh info for SFTP
# <https://serverfault.com/a/236437/132462>
. $HOME/.keychain/`/bin/hostname`-sh

# Don't automatically update this repo; cron might not have access rights.
# cd "$THIS_DIR" && git pull

# Check out <https://unix.stackexchange.com/a/368141/40432> on how to add the
# server key in advance.

"$THIS_DIR/boost.sh"
"$THIS_DIR/cgal.sh"
"$THIS_DIR/cmake.sh"
"$THIS_DIR/deal.ii.sh"
"$THIS_DIR/docker-gc.sh"
"$THIS_DIR/eigen3.sh"
#
"$THIS_DIR/git.sh"
"$THIS_DIR/gmsh.sh"
"$THIS_DIR/hdf5.sh"
"$THIS_DIR/lapack.sh"
"$THIS_DIR/lintian.sh"
"$THIS_DIR/llvm.sh"
"$THIS_DIR/lmms.sh"
"$THIS_DIR/matplotlib.sh"
"$THIS_DIR/mikado.sh"
"$THIS_DIR/mixxx.sh"
"$THIS_DIR/moab.sh"
"$THIS_DIR/mosh.sh"
"$THIS_DIR/netcdfcxx.sh"
"$THIS_DIR/netcdff.sh"
"$THIS_DIR/netcdf.sh"
"$THIS_DIR/numpy.sh"
"$THIS_DIR/openblas.sh"
"$THIS_DIR/paraview.sh"
"$THIS_DIR/petsc.sh"
"$THIS_DIR/scipy.sh"
"$THIS_DIR/seacas.sh"
"$THIS_DIR/swig.sh"
"$THIS_DIR/sympy.sh"
"$THIS_DIR/transmission.sh"
"$THIS_DIR/trilinos.sh"
"$THIS_DIR/vtk7.sh"
"$THIS_DIR/xdmf.sh"
#
"$THIS_DIR/fenics/01all.sh"
