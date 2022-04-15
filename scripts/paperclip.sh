#!/usr/bin/env bash

# Copied from https://github.com/PaperMC/Paper/blob/d54ce6c17fb7a35238d6b9f734d30a4289886773/scripts/paperclip.sh
# License from Paper applies to this file

set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/Paper/work"
localworkdir="$basedir/work"
mcver=1.8.8
paperjar="$basedir/WYSpIgot-Server/target/wyspigot-$mcver.jar"
vanillajar="$workdir/$mcver/$mcver.jar"

cd "$localworkdir/Paperclip"
mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$paperjar" "-Dvanillajar=$vanillajar" || exit 1
echo "Build success"

cp "$localworkdir/Paperclip/assembly/target/paperclip-${mcver}.jar" "$basedir/wyspigot-paperclip.jar"
echo "Copied final jar to root project dir"
