#!/bin/bash
# Download CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

dist_dir=$(readlink -f $(dirname "$0"))/dist
mkdir -p -- "${dist_dir}" || exit $?
cd -- "${dist_dir}" || exit $?

function dl () {
  md5=$1
  url=$2
  file=${3:-${2##*/}}
  if ! echo "${md5}  ${file}" | md5sum -c - >/dev/null 2>/dev/null ; then
    curl -R -L -o "${file}" "${url}" || exit $?
    md5sum -- "${file}"
    echo Update "$0" with new md5
    exit 1
  fi
}

# CFchecker
dl 12a1da84d9f2403510fa3c2aeb1278f1 'http://redmine.iek.fz-juelich.de/attachments/download/209/CFchecker-1.6.0.tar.bz2'
dl f93d2d41ad98a50ca4bfe9799ed807a0 'https://github.com/Unidata/netcdf4-python/archive/v1.1.1rel.tar.gz' 'netcdf4-python-1.1.1rel.tar.gz'
dl 39b29e3580c0604f7cafc44a00d2ec4b 'http://www.hdfgroup.org/ftp/HDF5/current/bin/linux-centos6-x86_64-gcc447/hdf5-1.8.14-linux-centos6-x86_64-gcc447-shared.tar.gz'
dl 2fd2365e1fe9685368cd6ab0ada532a0 'ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.2.tar.gz'
dl 78842b73560ec378142665e712ae4ad9 'http://downloads.sourceforge.net/project/numpy/NumPy/1.9.1/numpy-1.9.1.tar.gz'
dl e876322cac0d939b5dd9ce53ad708b7e 'https://cfunits-python.googlecode.com/files/cfunits-0.9.6.tar.gz'
dl b81ab8f24125ce18702ab7b3ca4d566f 'ftp://ftp.unidata.ucar.edu/pub/udunits/udunits-2.2.17.tar.gz'
dl f1675f0200e704dfcd8f83c7e82c81ff 'https://github.com/nose-devs/nose/archive/release_1.3.4.tar.gz' 'nose-release_1.3.4.tar.gz'

