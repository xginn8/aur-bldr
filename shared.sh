#!/bin/bash

function get_version()
{
    #echo "getting latest version from github"
    if ! grep -q "^pkgname=.*-git" PKGBUILD && ! grep -q "url=.https://github.com" PKGBUILD ; then
        #echo "Not a -git package and no upstream provided"
        if ! grep -q "^_github_url=.none.$" PKGBUILD ; then
            exit 1
        #else
            #echo "Exception in place, proceeding"
        fi
    fi
    local URL
    local VERSION
    URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/releases/latest@' | head -n1)
    #echo "URL: ${URL}"
    VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -r '.tag_name | sub("^v";"")')
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        URL=$(awk -F= '/url=.*github.com.*/{print $2}' PKGBUILD | sed -e 's@https://github.com@https://api.github.com/repos@' -e "s/[\'\"]//g" -e 's@$@/tags@' | head -n1)
        VERSION=$(curl -XGET -H "Accept: application/vnd.github.v3+json" "${URL}" | jq -Sr '.[].name | sub("^v";"") | match("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"; "g") | .string' | head -n1)

    fi
    echo "${VERSION}"
}
