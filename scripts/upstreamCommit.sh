#!/usr/bin/env bash
(
set -e
PS1="$"

function changelog() {
    base=$(git ls-tree HEAD $1  | cut -d' ' -f3 | cut -f1)
    cd $1 && git log --oneline ${base}...HEAD
}
tacospigot=$(changelog TacoSpigot)

updated=""
logsuffix=""
if [ ! -z "$tacospigot" ]; then
    logsuffix="$logsuffix\n\nTacoSpigot Changes:\n$tacospigot"
    if [ -z "$updated" ]; then updated="TacoSpigot"; else updated="$updated/TacoSpigot"; fi
fi
disclaimer="Upstream has released updates that appears to apply and compile correctly"

if [ ! -z "$1" ]; then
    disclaimer="$@"
fi

log="${UP_LOG_PREFIX}Updated Upstream ($updated)\n\n${disclaimer}${logsuffix}"

echo -e "$log" | git commit -F -

) || exit 1
