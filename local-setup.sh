#!/bin/bash
CLONE_DIR=${1}
mkdir -p "${CLONE_DIR}"
while IFS= read -r pkg
do
    PKGBASE="${CLONE_DIR}/${pkg}"
    if [ ! -d "${PKGBASE}" ]; then
        echo "${pkg} does not exist locally, cloning"
        git clone "ssh://aur@aur.archlinux.org/${pkg}.git" "${PKGBASE}"
    fi
    if ! diff -q pkg-pre-commit "${PKGBASE}/.git/hooks/pre-commit"; then
        echo "hook difference, installing pre-commit hook"
        cp pkg-pre-commit "${PKGBASE}/.git/hooks/pre-commit"
    fi
done < <(awk -F= '/^- AUR_PACKAGE=/{print $2}' .travis.yml)
