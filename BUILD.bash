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

# newer lxml
pip install lxml==3.4.1 || exit $?

# numpy
pip install numpy==1.9.1 || exit $?

# netcdf4
pip install netcdf4==1.1.1 || exit $?

# nose
pip install nose==1.3.4 || exit $?

# cfunits
cfu=cfunits-0.9.6
if ! [[ -e "${prefix}/lib/python2.6/site-packages/${cfu}-py2.6.egg-info" ]] ; then
  cd -- "${src_dir}" || exit $?
  if [[ -d "${cfu}" ]] ; then
    rm -r "${cfu}" || exit $?
  fi
  tar xf "${dist_dir}/${cfu}.tar.gz" || exit $?
  cd -- "${cfu}" || exit $?
  python setup.py install "--prefix=${prefix}" || exit $?
fi

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

