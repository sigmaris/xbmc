#!/bin/sh -e

. $(pwd)/buildconfig

if [ "$(uname -m)" == "aarch64" ]
then
	echo "Native aarch64 build..."
	docker build \
		--build-arg linux_libc_dev_release="$linux_libc_dev_release" \
		--build-arg linux_libc_dev_sha256="$linux_libc_dev_sha256" \
		--build-arg linux_libc_dev_file="$linux_libc_dev_file" \
		-t kodibuilder \
		.
else
	echo "Cross-platform build..."
	docker buildx build \
		--platform linux/arm64 \
		--build-arg linux_libc_dev_release="$linux_libc_dev_release" \
		--build-arg linux_libc_dev_sha256="$linux_libc_dev_sha256" \
		--build-arg linux_libc_dev_file="$linux_libc_dev_file" \
		-t kodibuilder \
		--load \
		.
fi

mkdir -p "$(pwd)/../../kodi-build"

docker run -v "$(pwd)/..:/kodi-src" -v "$(pwd)/../../kodi-build:/kodi-build" kodibuilder
