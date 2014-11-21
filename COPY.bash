#!/bin/bash
# Copy dist folder to target host

target_host=hotshot
target_dir=cfc

ssh "${target_host}" "mkdir -p -- ${target_dir}" || exit $?
rsync -av BUILD.bash dist "${target_host}:${target_dir}/"

