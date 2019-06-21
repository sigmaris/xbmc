FROM debian:buster

RUN apt-get update && apt-get install -y \
autoconf \
automake \
autopoint \
build-essential \
cmake \
curl \
debhelper \
default-jre \
dh-python \
doxygen \
fontforge-nox \
fonts-dejavu-core \
fonts-droid-fallback \
gawk \
gettext \
gperf \
groovy \
librsvg2-bin \
libasound2-dev \
libass-dev \
libavahi-client-dev \
libavahi-common-dev \
libbluetooth-dev \
libbluray-dev \
libcap-dev \
libcdio-dev \
libcec-dev \
libp8-platform-dev \
libcommons-lang-java \
libcurl4-gnutls-dev \
libcwiid-dev \
libdbus-1-dev \
libcrossguid-dev \
libdrm-dev \
libegl1-mesa-dev \
libenca-dev \
libfmt-dev \
libfontconfig-dev \
libfreetype6-dev \
libfribidi-dev \
libfstrcmp-dev \
libgbm-dev \
libgcrypt-dev \
libgif-dev \
libgles2-mesa-dev \
libglew-dev \
libglu1-mesa-dev \
libgnutls28-dev \
libgpg-error-dev \
libgtest-dev \
libinput-dev \
libiso9660-dev \
libjpeg-dev \
liblcms2-dev \
liblirc-dev \
libltdl-dev \
liblzo2-dev \
libmicrohttpd-dev \
default-libmysqlclient-dev \
libnfs-dev \
libpcre3-dev \
libplist-dev \
libpng-dev \
libpulse-dev \
libsmbclient-dev \
libsqlite3-dev \
libgcrypt-dev \
libssl-dev \
libtag1-dev \
libtinyxml-dev \
libtool \
libudev-dev \
libunistring-dev \
libva-dev \
libvdpau-dev \
libxkbcommon-dev \
libxrandr-dev \
libxslt1-dev \
libxt-dev \
python-dev \
rapidjson-dev \
swig \
unzip \
uuid-dev \
zip \
zlib1g-dev

# TODO enable shairplay

RUN mkdir /kodi-src && mkdir /kodi-build

VOLUME /kodi-src /kodi-build

WORKDIR /kodi-build

CMD cmake ../kodi-src \
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
  -DDEB_PACKAGE_ARCHITECTURE=amd64 \
  -DDEBIAN_PACKAGE_TYPE=unstable \
  -DDISTRO_CODENAME=buster \
  && \
  cmake --build . -- -j$(getconf _NPROCESSORS_ONLN)
