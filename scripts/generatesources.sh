#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. $(dirname $SOURCE)/init.sh


cd $basedir
flamepaperVer=$(cat current-flamepaper)

minecraftversion=$(cat "$basedir/FlamePaper/PaperSpigot/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
decompile="FlamePaper/work/$minecraftversion/"

mkdir -p mc-dev/src/net/minecraft/server

cd mc-dev
if [ ! -d ".git" ]; then
    git init
fi

rm src/net/minecraft/server/*.java
cp -r $basedir/$decompile/net/minecraft/server/* src/net/minecraft/server

base="$basedir/FlamePaper/FlamePaper-Server/src/main/java/net/minecraft/server"
cd $basedir/mc-dev/src/net/minecraft/server/
for file in $(/bin/ls $base)
do
    if [ -f "$file" ]; then
        rm -f "$file"
    fi
done
cd $basedir/mc-dev
git add . -A
git commit . -m "mc-dev"
git tag -a "$flamepaperVer" -m "$flamepaperVer" 2>/dev/null
pushRepo . $MCDEV_REPO $flamepaperVer
