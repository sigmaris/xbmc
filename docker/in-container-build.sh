#!/bin/bash

echo "************************"
echo "*** Configuring kodi ***"
echo "************************"

cmake ../kodi-src \
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
  -DDISTRO_CODENAME=buster \

echo "*********************"
echo "*** Building kodi ***"
echo "*********************"

cmake --build . -- -j$(getconf _NPROCESSORS_ONLN) \

echo "*********************"
echo "*** Building debs ***"
echo "*********************"

cpack
