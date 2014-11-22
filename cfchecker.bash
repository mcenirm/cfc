#!/bin/bash
# Run CFchecker (https://bitbucket.org/mde_/cfchecker)

declare -r prefix=$(readlink -f $(dirname "$0"))

export LD_LIBRARY_PATH=${prefix}/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}
export PYTHONPATH=${prefix}/lib64/python2.6/site-packages:${prefix}/lib/python2.6/site-packages${PYTHONPATH+:${PYTHONPATH}}

"${prefix}/bin/cfchecker" "$@"

