#!/bin/sh -ue

backportpackage \
  -u ppa:nschloe/gmsh-backports \
  -d trusty \
  gmsh \
  -v 2.10.1+dfsg1-1ubuntu4
