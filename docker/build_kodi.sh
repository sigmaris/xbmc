#!/bin/bash -e

REPO_DIR="$(realpath ../kodi-src)"

: "${KODI_PLATFORM_BUILD_NUMBER:=$DRONE_BUILD_NUMBER}"
: "${KODI_DISTRO_CODENAME:=$(lsb_release -cs)}"

echo "*********************"
echo "*** Building kodi ***"
echo "*********************"

cmake --build . -- -j$(getconf _NPROCESSORS_ONLN)

echo "**************************"
echo "*** Building kodi debs ***"
echo "**************************"

cpack

echo "********************************************"
echo "*** Installing binary addon dev packages ***"
echo "********************************************"

dpkg -i packages/kodi-addon-dev_*_all.deb

echo "*************************************"
echo "*** Building libkodiplatform debs ***"
echo "*************************************"

cd packages
git clone https://github.com/xbmc/kodi-platform.git
cd kodi-platform
sed -e "s/#TAGREV#/${KODI_PLATFORM_BUILD_NUMBER}/g" -e "s/#DIST#/${KODI_DISTRO_CODENAME}/g" debian/changelog.in > debian/changelog
dpkg-buildpackage -us -uc -b --jobs=auto

echo "*************"
echo "*** Done! ***"
echo "*************"
