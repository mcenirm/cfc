#!/bin/bash
# Build CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

declare -r prefix=$(readlink -f $(dirname "$0"))
declare -r dist_dir=${prefix}/dist
declare -r src_dir=${prefix}/src

virtualenv "${prefix}" || exit $?

source "${prefix}"/bin/activate || exit $?

export LD_LIBRARY_PATH=${prefix}/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}

mkdir -p -- "${src_dir}" || exit $?

# HDF5
if ! [[ -e "${prefix}/bin/h5dump" ]] ; then
  hdf5=hdf5-1.8.14
  cd -- "${src_dir}" || exit $?
  if [[ -d "${hdf5}" ]] ; then
    rm -r "${hdf5}" || exit $?
  fi
  tar xf "${dist_dir}/${hdf5}.tar.bz2" || exit $?
  cd -- "${hdf5}" || exit $?
  ./configure "--prefix=${prefix}" || exit $?
  make install || exit $?
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
  CPPFLAGS=-I${prefix}/include LDFLAGS=-L${prefix}/lib ./configure --prefix=${prefix} || exit $?
  make check install || exit $?
fi

# UDUNITS
udu=udunits-2.2.17
if ! [[ -e "${prefix}/bin/udunits2" ]] ; then
  cd -- "${src_dir}" || exit $?
  if [[ -d "${udu}" ]] ; then
    rm -r "${udu}" || exit $?
  fi
  tar xf "${dist_dir}/${udu}.tar.gz" || exit $?
  cd -- "${udu}" || exit $?
  ./configure "--prefix=${prefix}" || exit $?
  make || exit $?
  make install || exit $?
fi

function pip_or_easy () {
  pkg_name=$1
  pkg_version=$2
  pkg_dist=${3-${pkg_name}-${pkg_version}.tar.gz}
  cd -- "${prefix}" || exit $?
  if ! pip install "${pkg_name}==${pkg_version}" ; then
    easy_install -Z "${dist_dir}/${pkg_dist}" || exit $?
  fi
}

# nose
pip_or_easy nose 1.3.4 nose-release_1.3.4

# newer lxml
pip_or_easy lxml 3.4.1

# numpy
pip_or_easy numpy 1.9.1

# netcdf4
HDF5_DIR=${prefix} NETCDF4_DIR=${prefix} pip_or_easy netcdf4 1.1.1 netcdf4-python-1.1.1rel.tar.gz

# cfunits
pip_or_easy cfunits 0.9.6

# CFchecker
cfc=CFchecker
if ! [[ -e "${prefix}/bin/cfchecker" ]] ; then
  cd -- "${src_dir}" || exit $?
  if [[ -d "${cfc}" ]] ; then
    rm -r "${cfc}" || exit $?
  fi
  tar xf "${dist_dir}/${cfc}-1.6.0.tar.bz2" || exit $?
  cd -- "${cfc}" || exit $?
  python setup.py install "--prefix=${prefix}" || exit $?
fi

cd -- "${src_dir}/${cfc}" || exit $?
nosetests -v

