#!/bin/bash -e
RELEASE_DOWNLOAD_URL="https://github.com/sigmaris/xbmc/releases/download"

if [ -z "$DRONE_TAG" ]
then
	echo "No DRONE_TAG, can't fetch build tarball."
	exit 1
fi

KODI_TAG=${DRONE_TAG%"-addons"}
curl -L -o /tmp/kodi-build.tar.bz2 "${RELEASE_DOWNLOAD_URL}/${KODI_TAG}/kodi-build-${KODI_DISTRO_CODENAME}.tar.bz2"
tar xjvf /tmp/kodi-build.tar.bz2
