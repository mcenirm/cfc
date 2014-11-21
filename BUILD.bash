#!/bin/bash
# Build CFchecker (https://bitbucket.org/mde_/cfchecker)
# and any dependencies.

declare -r top_dir=$(readlink -f $(dirname "$0"))
declare -r dist_dir=${top_dir}/dist
declare -r src_dir=${top_dir}/src

mkdir -p -- "${src_dir}" || exit $?
cd -- "${src_dir}" || exit $?

tar xf "${dist_dir}/CFchecker-1.6.0.tar.bz2" || exit $?
cd -- CFchecker || exit $?
python setup.py

