#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$THIS_DIR/dijitso.sh"
"$THIS_DIR/ufl.sh"
"$THIS_DIR/fiat.sh"
"$THIS_DIR/instant.sh"
# Give the above packages time to build and publish.
sleep 3600
"$THIS_DIR/ffc.sh"
sleep 3600
"$THIS_DIR/mshr.sh"
"$THIS_DIR/dolfin.sh"
sleep 3600
"$THIS_DIR/fenics.sh"
