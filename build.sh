#!/bin/zsh

mksrcinfo () {
    makepkg --printsrcinfo > .SRCINFO
}

updpkg () {
    if [ -z ${VERSION+x} ]
    then
            echo "getting latest version from github"
            local URL
            local VERSION
            URL=$(awk -F= '/^_github_url=/ {print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/releases/latest@')
            VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.tag_name | sub("^v";"")')
    fi
    local OLD_VERSION
    local OLD_PKGREL
    OLD_VERSION=$(awk -F= '/^pkgver=[0-9\.]*$/{print $2}' PKGBUILD)
    autoload is-at-least
    OLD_PKGREL=$(awk -F= '/^pkgrel=[0-9\.]*$/{print $2}' PKGBUILD)
    if is-at-least "${VERSION}" "${OLD_VERSION}"
    then
            local NEW_PKGREL
            NEW_PKGREL=$(( OLD_PKGREL + 1 ))
            echo "updating pkgrel to ${NEW_PKGREL} from ${OLD_PKGREL}"
            sed -i "s/^pkgrel=[0-9\.]*$/pkgrel=${NEW_PKGREL}/g" PKGBUILD
    else
            echo "updating pkgrel to 1"
            sed -i "s/^pkgrel=[0-9\.]*$/pkgrel=1/g" PKGBUILD
    fi
    (sed -i "s/^pkgver=[0-9\.]*$/pkgver=${VERSION}/g" PKGBUILD && updpkgsums && mksrcinfo && makepkg -sriC --noconfirm --noprogressbar && \
        git add . && git commit -sm "update version to v${VERSION}") || (
            echo "reverting pkgrel to ${OLD_PKGREL}" && sed -i "s/^pkgrel=[0-9\.]*$/pkgrel=${OLD_PKGREL}/g" PKGBUILD
    )
}

sudo su -c 'reflector -n10 > /etc/pacman.d/mirrorlist'
BUILD_DIR=/home/bldr/builds

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
if [ -z "${AUR_PACKAGE}" ]; then
    echo "need to define \$AUR_PACKAGE, exiting"
    exit 1
fi

if [ -d "${BUILD_DIR}/${AUR_PACKAGE}" ]; then
    cd "${AUR_PACKAGE}" || exit 1
    git pull
else
    git clone "https://aur.archlinux.org/${AUR_PACKAGE}.git" "${BUILD_DIR}/${AUR_PACKAGE}"
fi
cd "${AUR_PACKAGE}" || exit 1
if [ -n "${UPDATE}" ]; then
    updpkg && makepkg -i --noconfirm && namcap ./*tar.xz && namcap PKGBUILD
else
    makepkg -sri --noconfirm --noprogressbar && namcap ./*tar.xz && namcap PKGBUILD
fi
