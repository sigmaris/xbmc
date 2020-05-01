#!/bin/bash

REPO_DIR="$(realpath ../kodi-src)"
KODI_BUILD_DIR="$(pwd)"

: "${ADDONS_BUILD_NUMBER:=$DRONE_BUILD_NUMBER}"
: "${KODI_DISTRO_CODENAME:=$(lsb_release -cs)}"

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
		ADDONS_PACK_VER=$(grep -oP "(  |\\t)version=\"(.*)\"" ./${D}/${VERSION_FILE} | awk -F'\"' '{print $2}')
		sed -e "s/#PACKAGEVERSION#/${ADDONS_PACK_VER}/g" -e "s/#TAGREV#/${ADDONS_BUILD_NUMBER}/g" -e "s/#DIST#/${KODI_DISTRO_CODENAME}/g" debian/changelog.in > debian/changelog
		if [[ $D == "pvr"* || $D == "audioencoder"* || $D == "visualization.waveform" ]]; then
			for F in $(ls debian/*.install); do
				echo "usr/lib" > ${F}
				echo "usr/share" >> ${F}
			done
		fi
		# if [[ $D == "audioencoder"* || $D == "audiodecoder"* ]]; then
		# 	sed -i "s/-DUSE_LTO=1//g" debian/rules
		# fi

		dpkg-buildpackage -us -uc -b --jobs=auto
		if [ $? -ne 0 ]
		then
			ADDONS_BUILD_FAILED+=("${D}")
		else
			ADDONS_BUILD_OK+=("${D}")
		fi
		cd ..
	fi
done

echo "********************************"
echo "*** Finished building addons ***"
echo "********************************"
echo ""
echo "Addons built OK: ${ADDONS_BUILD_OK[@]}"
echo ""
echo "Addons which failed to build: ${ADDONS_BUILD_FAILED[@]}"
