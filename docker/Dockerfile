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
git \
gperf \
groovy \
librsvg2-bin \
libasound2-dev \
libass-dev \
libavahi-client-dev \
libavahi-common-dev \
libavahi-core-dev \
libavahi-compat-libdnssd-dev \
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

# build shairplay
RUN git clone https://github.com/juhovh/shairplay.git
RUN cd /shairplay && ./autogen.sh && ./configure --disable-shared --enable-static --with-playfair --prefix=/shairplay-build && make -j$(getconf _NPROCESSORS_ONLN) install

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

ENV CMAKE_INCLUDE_PATH=/shairplay-build/include
ENV CMAKE_LIBRARY_PATH=/shairplay-build/lib

CMD /usr/local/bin/in-container-build.sh
