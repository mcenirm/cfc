#!/bin/bash
# Download CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

dist_dir=$(readlink -f $(dirname "$0"))/dist
mkdir -p -- "${dist_dir}" || exit $?
cd -- "${dist_dir}" || exit $?

function dl () {
  md5=$1
  url=$2
  file=${2##*/}
  if ! echo "${md5}  ${file}" | md5sum -c - >/dev/null 2>/dev/null ; then
    curl -RO "${url}" || exit $?
    md5sum -- "${file}"
    echo Update "$0" with new md5
    exit 1
  fi
}

# CFchecker
dl 12a1da84d9f2403510fa3c2aeb1278f1 'http://redmine.iek.fz-juelich.de/attachments/download/209/CFchecker-1.6.0.tar.bz2'

