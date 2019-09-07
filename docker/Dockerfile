FROM debian:buster

RUN curl -L https://github.com/sigmaris/rockpkgs/raw/master/pub.key | apt-key add -

RUN echo "deb http://sigmaris.github.io/rockpkgs buster main" > /etc/apt/sources.list.d/sigmarisrockpkgs.list

RUN apt-get update && apt-get install -y \
autoconf \
automake \
autopoint \
build-essential \
cmake \
curl \
debhelper \
default-jre \
default-libmysqlclient-dev \
dh-python \
doxygen \
fontforge-nox \
fonts-dejavu-core \
fonts-droid-fallback \
gawk \
gettext \
git \
gperf \
groovy \
libarchive-dev \
libasound2-dev \
libass-dev \
libavahi-client-dev \
libavahi-common-dev \
libavahi-core-dev \
libavahi-compat-libdnssd-dev \
libbluetooth-dev \
libbluray-dev \
libbz2-dev \
libcap-dev \
libcdio-dev \
libcec-dev \
libde265-dev \
libcommons-lang-java \
libcrossguid-dev \
libcurl4-gnutls-dev \
libcwiid-dev \
libdbus-1-dev \
libdrm-dev \
libegl1-mesa-dev \
libenca-dev \
libflac-dev \
libfluidsynth-dev \
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
libglm-dev \
libglu1-mesa-dev \
libgnutls28-dev \
libgpg-error-dev \
libgtest-dev \
libhdhomerun-dev \
libheif-dev \
libinput-dev \
libiso9660-dev \
libjpeg-dev \
libjsoncpp-dev \
liblcms2-dev \
liblirc-dev \
libltdl-dev \
liblz4-dev \
liblzma-dev \
liblzo2-dev \
libmagickcore-dev \
libmagickwand-6-headers \
libmagickwand-dev \
libmicrohttpd-dev \
libmodplug-dev \
libmp3lame-dev \
libnfs-dev \
libogg-dev \
libopenmpt-dev \
libp8-platform-dev \
libpcre3-dev \
libplist-dev \
libpng-dev \
libprojectm-dev \
libpulse-dev \
librapidxml-dev \
libraw-dev \
libresid-builder-dev \
librsvg2-bin \
librtmp-dev \
libshairplay-dev \
libsidplay2-dev \
libsmbclient-dev \
libsqlite3-dev \
libssh-dev \
libssl-dev \
libtag1-dev \
libtiff-dev \
libtinyxml-dev \
libtinyxml2-dev \
libtool \
libudev-dev \
libunistring-dev \
libva-dev \
libvdpau-dev \
libvorbis-dev \
libxkbcommon-dev \
libxrandr-dev \
libxslt1-dev \
libxt-dev \
lsb-release \
nlohmann-json3-dev \
pkg-config \
python-dev \
rapidjson-dev \
swig \
unzip \
uuid-dev \
zip \
zlib1g-dev

ARG linux_libc_dev_release
ARG linux_libc_dev_sha256
ARG linux_libc_dev_file

RUN curl -L -o "${linux_libc_dev_file}" "https://github.com/sigmaris/linux/releases/download/${linux_libc_dev_release}/${linux_libc_dev_file}" && \
  echo "${linux_libc_dev_sha256}  ${linux_libc_dev_file}" > sha256sums && \
  sha256sum --check sha256sums && \
  dpkg -i "${linux_libc_dev_file}" && \
  rm "${linux_libc_dev_file}" sha256sums

RUN mkdir /kodi-src && mkdir /kodi-build

COPY in-container-build.sh /usr/local/bin/in-container-build.sh
RUN chmod 0755 /usr/local/bin/in-container-build.sh

VOLUME /kodi-src /kodi-build

WORKDIR /kodi-build

CMD /usr/local/bin/in-container-build.sh
