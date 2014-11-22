#!/bin/bash
# Build CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

declare -r prefix=$(readlink -f $(dirname "$0"))
declare -r dist_dir=${prefix}/dist
declare -r src_dir=${prefix}/src

export LD_LIBRARY_PATH=${prefix}/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}

mkdir -p -- "${src_dir}" || exit $?

# HDF5
if ! [[ -e "${prefix}/bin/h5dump" ]] ; then
  hdf5=hdf5-1.8.14-linux-centos6-x86_64-gcc447-shared
  cd -- "${src_dir}" || exit $?
  if [[ -d "${hdf5}" ]] ; then
    rm -r "${hdf5}" || exit $?
  fi
  tar xf "${dist_dir}/${hdf5}.tar.gz" || exit $?
  rsync -a "${hdf5}"/{bin,include,lib} "${prefix}/"
  cd -- "${prefix}/bin" || exit $?
  echo 'yes' | ./h5redeploy || exit $?
fi

# netcdf4
if ! [[ -e "${prefix}/bin/ncdump" ]] ; then
  nc4=netcdf-4.3.2
  cd -- "${src_dir}" || exit $?
  if [[ -d "${nc4}" ]] ; then
    rm -r "${nc4}" || exit $?
  fi
  tar xf "${dist_dir}/${nc4}.tar.gz" || exit $?
  cd -- "${nc4}" || exit $?
  CPPFLAGS=-I${prefix}/include LDFLAGS=-L${prefix}/lib ./configure --prefix=${prefix}
  make check install
fi

# netcdf4-python
#if ! [[ -e "${prefix}/bin/h5dump" ]] ; then
  nc4py=netcdf4-python-1.1.1rel
  cd -- "${src_dir}" || exit $?
  if [[ -d "${nc4py}" ]] ; then
    rm -r "${nc4py}" || exit $?
  fi
  tar xf "${dist_dir}/${nc4py}.tar.gz" || exit $?
  cd -- "${nc4py}" || exit $?
  HDF5_DIR=${prefix} python setup.py
#fi

