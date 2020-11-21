#!/bin/bash -e
# Meant to be run in the build directory, this downloads and extracts
# kodi-addon-dev and libkodiplatform packages into packages/
RELEASE_DOWNLOAD_URL="https://github.com/sigmaris/xbmc/releases/download"

if [ -z "$DRONE_TAG" ]
then
	echo "No DRONE_TAG, can't fetch build tarball."
	exit 1
fi

if [[ "$DRONE_TAG" == *-games ]]
then
	KODI_TAG=${DRONE_TAG%-games}
else
	KODI_TAG=${DRONE_TAG%-addons}
fi

curl -L -o /tmp/addons-dev.tar.bz2 "${RELEASE_DOWNLOAD_URL}/${KODI_TAG}/addons-dev-${KODI_DISTRO_CODENAME}.tar.bz2"
tar xjvf /tmp/addons-dev.tar.bz2
