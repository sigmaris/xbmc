#!/bin/bash

REPO_DIR="$(realpath ../kodi-src)"
KODI_BUILD_DIR="$(pwd)"

: "${ADDONS_BUILD_NUMBER:=$DRONE_BUILD_NUMBER}"
: "${KODI_DISTRO_CODENAME:=$(lsb_release -cs)}"

cd build/addons_build

echo "**************************"
echo "*** Building addons... ***"
echo "**************************"

declare -a ADDONS_BUILD_OK
declare -a ADDONS_BUILD_FAILED

for D in $(ls . --ignore="*prefix")
do
	if [ -d "${D}/debian" ]
	then

		# Build libretro core libraries
		if [[ "${D}" == game.libretro.* ]]
		then
			for DEP in ${D}/depends/common/*
			do
				BASE_DEP="$(basename "$DEP")"
				echo "**********************************************"
				echo "*** Building libretro dependency $BASE_DEP ***"
				echo "**********************************************"
				cmake --build . --target "$BASE_DEP" -- -j$(getconf _NPROCESSORS_ONLN)

				if [ $? -ne 0 ]
				then
					ADDONS_BUILD_FAILED+=("${D}(${BASE_DEP})")
					continue 2
				fi

				# Remove build dependency on this libretro core
				sed -e 's/kodi-addon-dev,/kodi-addon-dev/' -e "/libretro-${BASE_DEP} \(.*\) \| ${BASE_DEP} \(.*\)/d" "${D}/debian/control" > "${D}/debian/control.new"
				mv "${D}/debian/control.new" "${D}/debian/control"
			done
			# Set env variable during build so this built lib is found & used
			EXTRA_ENV="CMAKE_LIBRARY_PATH=${KODI_BUILD_DIR}/build/lib"
		else
			EXTRA_ENV=""
		fi

		cd "${D}"
		echo "********************************"
		echo "*** Building binary addon $D ***"
		echo "********************************"
		VERSION_FILE="addon.xml.in"
		[[ ! -f "${D}/addon.xml.in" ]] && VERSION_FILE="addon.xml"
		ADDONS_PACK_VER=$(grep -oP "(  |\\t)version=\"(.*)\"" ./${D}/${VERSION_FILE} | awk -F'\"' '{print $2}')
		sed -e "s/#PACKAGEVERSION#/${ADDONS_PACK_VER}/g" -e "s/#TAGREV#/${ADDONS_BUILD_NUMBER}/g" -e "s/#DIST#/${KODI_DISTRO_CODENAME}/g" debian/changelog.in > debian/changelog

		env $EXTRA_ENV dpkg-buildpackage -us -uc -b --jobs=auto

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
