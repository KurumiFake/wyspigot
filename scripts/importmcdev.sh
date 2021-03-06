#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. $(dirname $SOURCE)/init.sh

workdir="$basedir"/FlamePaper/work
minecraftversion=$(cat "$basedir/FlamePaper/PaperSpigot/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
decompiledir=$workdir/$minecraftversion

nms="net/minecraft/server"
export MODLOG=""
cd "$basedir"

function containsElement {
    local e
    for e in "${@:2}"; do
        [[ "$e" == "$1" ]] && return 0;
    done
    return 1
}

export importedmcdev=""
function import {
    if [ -f "$basedir/FlamePaper/FlamePaper-Server/src/main/java/$nms/$1.java" ]; then
        echo "ALREADY IMPORTED $1"
        return 0
    fi
    export importedmcdev="$importedmcdev $1"
    file="${1}.java"
    target="$basedir/FlamePaper/FlamePaper-Server/src/main/java/$nms/$file"
    base="$decompiledir/$nms/$file"

    if [[ ! -f "$target" ]]; then
        export MODLOG="$MODLOG  Imported $file from mc-dev\n";
        echo "Copying $base to $target"
        cp "$base" "$target"
    else
        echo "UN-NEEDED IMPORT STATEMENT: $file"
    fi
}

function importLibrary {
    group=$1
    lib=$2
    prefix=$3
    shift 3
    for file in "$@"; do
        file="$prefix/$file"
        target="$basedir/FlamePaper/FlamePaper-Server/src/main/java/$file"
        targetdir=$(dirname "$target")
        mkdir -p "${targetdir}"
        base="$workdir/Minecraft/$minecraftversion/libraries/${group}/${lib}/$file"
        if [ ! -f "$base" ]; then
            echo "Missing $base"
            exit 1
        fi
        export MODLOG="$MODLOG  Imported $file from $lib\n";
        sed 's/\r$//' "$base" > "$target" || exit 1
    done
}

(
    cd FlamePaper/FlamePaper-Server/
    lastlog=$(git log -1 --oneline)
    if [[ "$lastlog" = *"WYSpIgot-Extra mc-dev Imports"* ]]; then
        git reset --hard HEAD^
    fi
)


files=$(cat patches/server/* | grep "+++ b/src/main/java/net/minecraft/server/" | sort | uniq | sed 's/\+\+\+ b\/src\/main\/java\/net\/minecraft\/server\///g' | sed 's/.java//g')

nonnms=$(cat patches/server/* | grep "create mode " | grep -Po "src/main/java/net/minecraft/server/(.*?).java" | sort | uniq | sed 's/src\/main\/java\/net\/minecraft\/server\///g' | sed 's/.java//g')

for f in $files; do
    containsElement "$f" ${nonnms[@]}
    if [ "$?" == "1" ]; then
        if [ ! -f "$basedir/FlamePaper/FlamePaper-Server/src/main/java/net/minecraft/server/$f.java" ]; then
            if [ ! -f "$decompiledir/$nms/$f.java" ]; then
                if [[ ! $f == WYSpIgot* ]]; then
                    echo " ERROR!!! Missing NMS $f";
                fi
            else
                import $f
            fi
        fi
    fi
done

#import LegacyPingHandler
#import PacketDecoder
#import PacketEncoder
#import PacketDataSerializer
#import MCUtil
import BlockState
import BlockStateBoolean
import BlockStateEnum
import BlockStateInteger
import BlockStateList
import CommandScoreboard
import EULA
import IBlockState
import PacketLoginInEncryptionBegin
########################################################
########################################################
########################################################
#              LIBRARY IMPORTS
# These must always be mapped manually, no automatic stuff
#
#             # group    # lib          # prefix               # many files

#importLibrary com.mojang datafixerupper com/mojang/datafixers/util Either.java
################
(
    cd FlamePaper/FlamePaper-Server/
    rm -rf nms-patches
    git add src -A
    echo -e "WYSpIgot-Extra mc-dev Imports\n\n$MODLOG" | git commit src -F -
    exit 0
)
