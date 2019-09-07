#!/bin/bash

REPO_DIR="$(realpath ../kodi-src)"
KODI_BUILD_DIR="$(pwd)"
ADDONS_BUILD_NUMBER="1"

echo "************************"
echo "*** Configuring kodi ***"
echo "************************"

cmake "${REPO_DIR}" \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_BUILD_TYPE=Release \
  -DCORE_PLATFORM_NAME=gbm \
  -DGBM_RENDER_SYSTEM=gles \
  -DENABLE_OPENGL=OFF \
  -DENABLE_OPENGLES=ON \
  -DENABLE_AIRTUNES=ON \
  -DENABLE_ALSA=ON \
  -DENABLE_AVAHI=ON \
  -DENABLE_BLURAY=ON \
  -DENABLE_CEC=ON \
  -DENABLE_DBUS=ON \
  -DENABLE_DVDCSS=ON \
  -DENABLE_EGL=ON \
  -DENABLE_EVENTCLIENTS=ON \
  -DENABLE_INTERNAL_FFMPEG=ON \
  -DENABLE_V4L2=ON \
  -DENABLE_INTERNAL_CROSSGUID=OFF \
  -DENABLE_INTERNAL_FLATBUFFERS=ON \
  -DENABLE_MICROHTTPD=ON \
  -DENABLE_MYSQLCLIENT=ON \
  -DENABLE_NFS=ON \
  -DENABLE_OPENSSL=ON \
  -DENABLE_OPTICAL=ON \
  -DENABLE_PULSEAUDIO=ON \
  -DENABLE_SMBCLIENT=ON \
  -DENABLE_SSH=ON \
  -DENABLE_UDEV=ON \
  -DENABLE_UPNP=ON \
  -DENABLE_XSLT=ON \
  -DENABLE_LIRC=ON \
  -DCPACK_GENERATOR=DEB \
  -DDEBIAN_PACKAGE_VERSION='1~' \
  -DDEB_PACKAGE_ARCHITECTURE=arm64 \
  -DDEBIAN_PACKAGE_TYPE=unstable \
  -DDISTRO_CODENAME=buster

echo "*********************"
echo "*** Building kodi ***"
echo "*********************"

cmake --build . -- -j$(getconf _NPROCESSORS_ONLN) \

echo "*********************"
echo "*** Building debs ***"
echo "*********************"

cpack

echo "*******************************************"
echo "*** Installing binary addon dev package ***"
echo "*******************************************"

dpkg -i packages/kodi-addon-dev_*_all.deb

echo "*********************************"
echo "*** Configuring binary addons ***"
echo "*********************************"

mkdir -p build/addons_build
cd build/addons_build
cmake -DBUILD_DIR="$(pwd)" -DCORE_SOURCE_DIR="${REPO_DIR}" -DADDONS_TO_BUILD="${ADDONS_TO_BUILD}" -DADDON_DEPENDS_PATH="${KODI_BUILD_DIR}/build" "${REPO_DIR}/cmake/addons/"

declare -a ADDONS_BUILD_OK
declare -a ADDONS_BUILD_FAILED

for D in $(ls . --ignore="*prefix")
do
	if [ -d "${D}/debian" ]
	then
		cd "${D}"
		echo "*** Building binary addon $D ***"
		VERSION_FILE="addon.xml.in"
		[[ ! -f "${D}/addon.xml.in" ]] && VERSION_FILE="addon.xml"
		ADDONS_PACK_VER=$(grep -oP "  version=\"(.*)\"" ./${D}/${VERSION_FILE} | awk -F'\"' '{print $2}')
		sed -e "s/#PACKAGEVERSION#/${ADDONS_PACK_VER}/g" -e "s/#TAGREV#/${ADDONS_BUILD_NUMBER}/g" -e "s/#DIST#/$(lsb_release -cs)/g" debian/changelog.in > debian/changelog
		if [[ $D == "pvr"* || $D == "audioencoder"* || $D == "visualization.waveform" ]]; then
			for F in $(ls debian/*.install); do
				echo "usr/lib" > ${F}
				echo "usr/share" >> ${F}
			done
		fi
		# if [[ $D == "audioencoder"* || $D == "audiodecoder"* ]]; then
		# 	sed -i "s/-DUSE_LTO=1//g" debian/rules
		# fi

		dpkg-buildpackage -us -uc -b
		if [ $? -ne 0 ]
		then
			ADDONS_BUILD_FAILED+=("${D}")
		else
			ADDONS_BUILD_OK+=("${D}")
		fi
		cd ..
	fi
done

echo "Addons built OK: ${ADDONS_BUILD_OK[@]}"
echo "Addons which failed to build: ${ADDONS_BUILD_FAILED[@]}"
