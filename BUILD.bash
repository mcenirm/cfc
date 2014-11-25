#!/bin/bash
# Build CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

declare -r prefix=$(readlink -f $(dirname "$0"))
declare -r dist_dir=${prefix}/dist
declare -r src_dir=${prefix}/src

export LD_LIBRARY_PATH=${prefix}/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}
export PYTHONPATH=${prefix}/lib64/python2.6/site-packages:${prefix}/lib/python2.6/site-packages${PYTHONPATH+:${PYTHONPATH}}
export PATH=${prefix}/bin${PATH+:${PATH}}

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

# numpy
if ! [[ -e "${prefix}/bin/f2py" ]] ; then
  numpy=numpy-1.9.1
  cd -- "${src_dir}" || exit $?
  if [[ -d "${numpy}" ]] ; then
    rm -r "${numpy}" || exit $?
  fi
  tar xf "${dist_dir}/${numpy}.tar.gz" || exit $?
  cd -- "${numpy}" || exit $?
  python setup.py install "--prefix=${prefix}" || exit $?
fi

# netcdf4-python
if ! [[ -e "${prefix}/bin/ncinfo" ]] ; then
  nc4py=netcdf4-python-1.1.1rel
  cd -- "${src_dir}" || exit $?
  if [[ -d "${nc4py}" ]] ; then
    rm -r "${nc4py}" || exit $?
  fi
  tar xf "${dist_dir}/${nc4py}.tar.gz" || exit $?
  cd -- "${nc4py}" || exit $?
  HDF5_DIR=${prefix} NETCDF4_DIR=${prefix} python setup.py install "--prefix=${prefix}" || exit $?
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

# nose
if ! [[ -e "${prefix}/bin/nosetests" ]] ; then
  nose=nose-release_1.3.4
  cd -- "${src_dir}" || exit $?
  if [[ -d "${nose}" ]] ; then
    rm -r "${nose}" || exit $?
  fi
  tar xf "${dist_dir}/${nose}.tar.gz" || exit $?
  cd -- "${nose}" || exit $?
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

