#!/bin/bash

source ./shared.sh

source_file="$(pwd)/package-versions"

truncate -s 0 "${source_file}"

mapfile -t packages < <(yq r .travis.yml 'env[*]' | awk -F= '{print $2}')
if (( ${#packages[@]} > 0 )); then
    for package in "${packages[@]}"; do
        yay -G "${package}"
        cd "${package}" || exit
        echo "${package}" "$(get_version)" >> "${source_file}"
        cd - || exit
        rm -rf "${package}"
    done
fi

git diff && echo "New versions detected" && exit 1
