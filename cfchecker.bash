#!/bin/bash
# Run CFchecker (https://bitbucket.org/mde_/cfchecker)

declare -r prefix=$(readlink -f $(dirname "$0"))

source "${prefix}/bin/activate"
export LD_LIBRARY_PATH=${prefix}/lib${LD_LIBRARY_PATH+:${LD_LIBRARY_PATH}}

"${prefix}/bin/cfchecker" "$@"

