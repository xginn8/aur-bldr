#!/bin/zsh

BASE_DIR=/home/bldr
mksrcinfo () {
    makepkg --printsrcinfo > .SRCINFO
}

updpkg () {
    echo "getting latest version from github"
    if ! grep -q "^pkgname=.*-git" PKGBUILD && ! grep -q "url=.https://github.com" PKGBUILD ; then
        echo "Not a -git package and no upstream provided"
        if ! grep -q "^_github_url=.none.$" PKGBUILD ; then
            exit 1
        else
            echo "Exception in place, proceeding"
        fi
    fi
    local URL
    local VERSION
    URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/releases/latest@' | head -n1)
    echo "URL: ${URL}"
    VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.tag_name | sub("^v";"")')
    if [ $? -ne 0 ]; then
        URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/tags@' | head -n1)
        VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -Sr '.[].name | sub("^v";"") | match("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"; "g") | .string' | head -n1)

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
    else
        yay --noconfirm --noprogressbar --builddir .. -S "${AUR_PACKAGE}" || makepkg -sriC --noconfirm --noprogressbar
    fi
    namcap ./*pkg.*tar.xz && namcap ./PKGBUILD
}

if [ -z "${AUR_PACKAGE}" ]; then
    echo "need to define \$AUR_PACKAGE, exiting"
    exit 1
fi

sudo su -c 'reflector -n10 -p http > /etc/pacman.d/mirrorlist && pacman -Syyu --noconfirm --noprogressbar'
cd "${BASE_DIR}"
yay -G "${AUR_PACKAGE}"
cd ${AUR_PACKAGE}
if ! diff -q "${BASE_DIR}/pkg-gitignore" .gitignore; then
        echo "Nonstandard gitignore" && exit 1
fi
updpkg
