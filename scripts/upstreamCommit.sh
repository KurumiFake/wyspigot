#!/usr/bin/env bash
(
set -e
PS1="$"

function changelog() {
    base=$(git ls-tree HEAD $1  | cut -d' ' -f3 | cut -f1)
    cd $1 && git log --oneline ${base}...HEAD
}
flamepaper=$(changelog FlamePaper)

updated=""
logsuffix=""
if [ ! -z "$flamepaper" ]; then
    logsuffix="$logsuffix\n\nFlamePaper Changes:\n$flamepaper"
    if [ -z "$updated" ]; then updated="FlamePaper"; else updated="$updated/FlamePaper"; fi
fi
disclaimer="Upstream has released updates that appears to apply and compile correctly"

if [ ! -z "$1" ]; then
    disclaimer="$@"
fi

log="${UP_LOG_PREFIX}Updated Upstream ($updated)\n\n${disclaimer}${logsuffix}"

echo -e "$log" | git commit -F -

) || exit 1
