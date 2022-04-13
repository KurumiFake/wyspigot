#!/usr/bin/env bash

# Copied from https://github.com/PaperMC/Paper/blob/d54ce6c17fb7a35238d6b9f734d30a4289886773/scripts/paperclip.sh
# License from Paper applies to this file

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/FlamePaper/Paper/work"
localworkdir="$basedir/work"
mcver=1.8.8
paperjar="$basedir/WYSpIgot-Server/target/wyspigot-$mcver.jar"
vanillajar="$workdir/Minecraft/$mcver/$mcver.jar"

(
    cd "$localworkdir/Paperclip"
    mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$paperjar" "-Dvanillajar=$vanillajar"
)
cp "$localworkdir/Paperclip/assembly/target/paperclip-${mcver}.jar" "$basedir/wyspigot-paperclip.jar"

echo ""
echo ""
echo ""
echo "Build success!"
echo "Copied final jar to $(cd "$basedir" && pwd -P)/wyspigot-paperclip.jar"
) || exit 1
