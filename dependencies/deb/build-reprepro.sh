#!/bin/sh
set -e

VERSION=5.3.0

cd /data/deb

echo "deb-src http://us.archive.ubuntu.com/ubuntu/ disco universe" >> /etc/apt/sources.list
apt-get update
apt-get upgrade -y
apt-get install -y dpkg-dev debhelper libarchive-dev libdb-dev libbz2-dev libgpgme11-dev liblzma-dev libz-dev
apt-get source reprepro
sed -i 's/libgpgme-dev/libgpgme11-dev/' reprepro-$VERSION/debian/control
cd reprepro-$VERSION
dpkg-buildpackage -rfakeroot -uc -b
