#!/bin/sh

docker build -t kodibuilder .

docker run -v `pwd`/..:/kodi-src -v `pwd`/../../kodi-build:/kodi-build kodibuilder
