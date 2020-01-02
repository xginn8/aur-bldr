#!/bin/zsh

mksrcinfo () {
    makepkg --printsrcinfo > .SRCINFO
}

updpkg () {
    echo "getting latest version from github"
    local URL
    local VERSION
    URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/releases/latest@')
    echo "URL: ${URL}"
    VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.tag_name | sub("^v";"")')
    if [ $? -ne 0 ]; then
        URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/tags@')
        VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.[0].name | sub("^v";"")')

    fi
    local OLD_VERSION
    local OLD_PKGREL

    echo "VERSION: ${VERSION}"
    echo "URL: ${URL}"
    OLD_VERSION=$(awk -F= '/^pkgver=[0-9a-z\.]*$/{print $2}' PKGBUILD)
    echo "OLD_VERSION: ${OLD_VERSION}"
    autoload is-at-least
    OLD_PKGREL=$(awk -F= '/^pkgrel=[0-9\.]*$/{print $2}' PKGBUILD)
    if ! grep -q "^pkgname=.*-git$" PKGBUILD && [ -n "${VERSION}" ] && ! is-at-least "${VERSION}" "${OLD_VERSION}";
    then
            sed -i "s/^pkgrel=[0-9\.]*$/pkgrel=1/g" PKGBUILD
            sed -i "s/^pkgver=[0-9\.]*$/pkgver=${VERSION}/g" PKGBUILD
            updpkgsums && mksrcinfo && makepkg -sriC --noconfirm --noprogressbar && \
                git add . && git commit -sm "update version to v${VERSION}"
            echo "New version available (${VERSION})!" && exit 1
    fi
    yay --noconfirm --noprogressbar -S "${AUR_PACKAGE}"
    cd "/home/bldr/.cache/yay/${AUR_PACKAGE}"
    namcap ./*tar.xz && namcap ./PKGBUILD
}

sudo su -c 'reflector -n10 > /etc/pacman.d/mirrorlist'
if [ -z "${AUR_PACKAGE}" ]; then
    echo "need to define \$AUR_PACKAGE, exiting"
    exit 1
fi

git config user.email "${AUR_MAINTAINER_EMAIL}"
git config user.name "${AUR_MAINTAINER_NAME}"
git config user.username "${AUR_MAINTAINER_USERNAME}"
updpkg
