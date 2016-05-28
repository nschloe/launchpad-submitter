#!/bin/sh -ue

"$HOME/rcs/launchpadtools/tools/launchpad-backport" \
  --orig "http://http.debian.net/debian/pool/main/m/metis/metis_5.1.0.dfsg-4.dsc" \
  --ubuntu-releases trusty \
  --ppa nschloe/metis-backports
