#!/bin/zsh

BASE_DIR=$(pwd)

source ./shared.sh

mksrcinfo () {
    makepkg --printsrcinfo > .SRCINFO
}

updpkg () {
    local old_version
    local version
    version=$(get_version)

    echo "version: ${version}"
    old_version=$(awk -F= '/^pkgver=[0-9a-z\.]*$/{print $2}' PKGBUILD)
    echo "old_version: ${old_version}"
    autoload is-at-least
    if ! grep -q "^pkgname=.*-git$" pkgbuild && [ -n "${version}" ] && ! is-at-least "${version}" "${old_version}";
    then
            sed -i "s/^pkgrel=[0-9\.]*$/pkgrel=1/g" PKGBUILD
            sed -i "s/^pkgver=[0-9\.]*$/pkgver=${version}/g" PKGBUILD
            updpkgsums && mksrcinfo && makepkg -sriC --noconfirm --noprogressbar
                 #&& git add . && git commit -sm "update version to v${VERSION}"
    else
        yay --noconfirm --noprogressbar --builddir .. -S "${AUR_PACKAGE}" || makepkg -sriC --noconfirm --noprogressbar
    fi
    namcap ./*pkg.*tar.xz && namcap ./PKGBUILD
}

if [ -z "${AUR_PACKAGE}" ]; then
    echo "need to define \$AUR_PACKAGE, exiting"
    exit 1
fi

sudo su -c 'reflector -n10 -p http > /etc/pacman.d/mirrorlist && pacman -Syu --noconfirm --noprogressbar'
cd "${BASE_DIR}"
yay -G "${AUR_PACKAGE}"
cd ${AUR_PACKAGE}
if ! diff -q "${BASE_DIR}/pkg-gitignore" .gitignore; then
        echo "Nonstandard gitignore" && exit 1
fi
updpkg
