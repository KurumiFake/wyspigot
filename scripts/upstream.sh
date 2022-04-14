#!/usr/bin/env bash
# get base dir regardless of execution location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
. $(dirname $SOURCE)/init.sh

git submodule update --init --recursive

if [[ "$1" == up* ]]; then
    (
        cd "$basedir/TacoSpigot/"
		git fetch && git reset --hard origin/dev
        cd ../
        git add TacoSpigot
    )
fi

tacospigotVer=$(gethead TacoSpigot)
cd "$basedir/TacoSpigot/"

git submodule update --init && ./remap.sh && ./decompile.sh && ./init.sh && ./applyPatches.sh

cd "TacoSpigot-Server"
mcVer=$(mvn -o org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate -Dexpression=minecraft_version | sed -n -e '/^\[.*\]/ !{ /^[0-9]/ { p; q } }')

basedir
. $basedir/scripts/importmcdev.sh

minecraftversion=1.8.8
version=$(echo -e "TacoSpigot: $tacospigotVer\nmc-dev:$importedmcdev")
tag="${minecraftversion}-${mcVer}-$(echo -e $version | shasum | awk '{print $1}')"
echo "$tag" > "$basedir"/current-tacospigot

"$basedir"/scripts/generatesources.sh

cd TacoSpigot/

function tag {
(
    cd $1
    if [ "$2" == "1" ]; then
        git tag -d "$tag" 2>/dev/null
    fi
    echo -e "$(date)\n\n$version" | git tag -a "$tag" -F - 2>/dev/null
)
}
echo "Tagging as $tag"
echo -e "$version"

forcetag=0
if [ "$(cat "$basedir"/current-tacospigot)" != "$tag" ]; then
    forcetag=1
fi

tag TacoSpigot-API $forcetag
tag TacoSpigot-Server $forcetag

pushRepo TacoSpigot-API $TACOSPIGOT_API_REPO $tag
pushRepo TacoSpigot-Server $TACOSPIGOT_SERVER_REPO $tag
