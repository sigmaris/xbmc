#!/bin/bash -e

: "${BINTRAY_USER:=sigmaris}"

kodi_version="$(set -- kodi_*_all.deb; echo "$1" | cut -d '_' -f 2)"
if [[ -z "$kodi_version" ]]
then
	echo "Can't detect Kodi version from these files:"
	ls
	exit 1
fi

echo "*********************************"
echo "*** Uploading built artifacts ***"
echo "*********************************"

for pkgfile in *.deb
do
	echo " ${pkgfile}..."
	curl -s -T "$pkgfile" --netrc-file <(cat <<<"machine api.bintray.com login $BINTRAY_USER password $BINTRAY_API_KEY") "https://api.bintray.com/content/${BINTRAY_USER}/artifacts/kodi/${kodi_version}/${pkgfile}"
	echo ""
done

echo "*************"
echo "*** Done! ***"
echo "*************"
