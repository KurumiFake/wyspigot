#!/usr/bin/env bash
# BEGIN config
FORK_NAME="WYSpIgot"
API_REPO=""
SERVER_REPO=""
FLAMEPAPER_API_REPO=""
FLAMEPAPER_SERVER_REPO=""
MCDEV_REPO=""
# END config

sourceBase=$(dirname $SOURCE)/../
cd "${basedir:-$sourceBase}"

basedir=$(pwd -P)
cd -

function cleanupPatches {
    cd "$1"
    for patch in *.patch; do
        gitver=$(tail -n 2 $patch | grep -ve "^$" | tail -n 1)
        diffs=$(git diff --staged $patch | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index|Date\: )")

        testver=$(echo "$diffs" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "$gitver")
        if [ "x$testver" != "x" ]; then
            diffs=$(echo "$diffs" | tail -n +3)
        fi

        if [ "x$diffs" == "x" ] ; then
            git reset HEAD $patch >/dev/null
            git checkout -- $patch >/dev/null
        fi
    done
}
function pushRepo {
    if [ "$(git config minecraft.push-${FORK_NAME})" == "1" ]; then
    echo "Pushing - $1 ($3) to $2"
    (
        cd "$1"
        git remote rm wysi-push > /dev/null 2>&1
        git remote add wysi-push $2 >/dev/null 2>&1
        git push wysi-push $3 -f
    )
    fi
}
function basedir {
    cd "$basedir"
}
function gethead {
    (
        cd "$1"
        git log -1 --oneline
    )
}
