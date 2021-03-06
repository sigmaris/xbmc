#!/bin/bash -e

REPO_DIR="$(realpath ../kodi-src)"
ADDONS_TYPE="${1:-*}"

echo "*****************************"
echo "*** Patching addon source ***"
echo "*****************************"

cd build/addons_build
for patch in ${REPO_DIR}/docker/patches/addons/${ADDONS_TYPE}/*.patch
do
	if [ -f "$patch" ]
	then
		patch -p1 < $patch
	fi
done

echo "***********************"
echo "*** Prepared addons ***"
echo "***********************"
