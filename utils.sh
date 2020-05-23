#!/bin/zsh

get_version_info () {
    if ! grep -q "^pkgname=.*-git" PKGBUILD && ! grep -q "url=.https://github.com" PKGBUILD ; then
        if ! grep -q "^_github_url=.none.$" PKGBUILD ; then
            exit 1
        else
        fi
    fi
    local URL
    local VERSION
    URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/releases/latest@' | head -n1)
    VERSION=$(curl -H "authorization: bearer ${GH_TOKEN}" -qs -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.tag_name | sub("^v";"")' 2>/dev/null)
    if [ $? -ne 0 ]; then
        URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/tags@' | head -n1)
        echo "${URL}"
        VERSION=$(curl -H "authorization: bearer ${GH_TOKEN}" -qs -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -Sr '.[].name | sub("^v";"") | match("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"; "g") | .string' | head -n1)

    fi
    local OLD_VERSION
    local OLD_PKGREL

    OLD_VERSION=$(awk -F= '/^pkgver=[0-9a-z\.]*$/{print $2}' PKGBUILD)
    autoload is-at-least
    OLD_PKGREL=$(awk -F= '/^pkgrel=[0-9\.]*$/{print $2}' PKGBUILD)
    if ! grep -q "^pkgname=.*-git$" PKGBUILD && [ -n "${VERSION}" ] && ! is-at-least "${VERSION}" "${OLD_VERSION}";
    then
            echo "${AUR_PACKAGE}=${VERSION}"
    else
            echo "${AUR_PACKAGE}=${OLD_VERSION}"

    fi
}

yay -G "${AUR_PACKAGE}" > /dev/null 2>&1
cd "${AUR_PACKAGE}"
get_version_info
