#!/bin/bash -e

REPO_DIR="$(realpath ../kodi-src)"
KODI_BUILD_DIR="$(pwd)"

echo "********************************************"
echo "*** Installing binary addon dev packages ***"
echo "********************************************"

dpkg -i packages/kodi-addon-dev_*_all.deb packages/libkodiplatform*.deb

echo "*********************************"
echo "*** Configuring binary addons ***"
echo "*********************************"

mkdir -p build/addons_build
cd build/addons_build
cmake -DBUILD_DIR="$(pwd)" -DCORE_SOURCE_DIR="${REPO_DIR}" -DADDONS_TO_BUILD="${ADDONS_TO_BUILD}" -DADDON_DEPENDS_PATH="${KODI_BUILD_DIR}/build" "${REPO_DIR}/cmake/addons/"

echo "***********************"
echo "*** Prepared addons ***"
echo "***********************"
