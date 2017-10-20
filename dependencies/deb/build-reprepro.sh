#!/bin/sh
set -e

cd /data/deb

echo "deb-src http://us.archive.ubuntu.com/ubuntu/ zesty universe" >> /etc/apt/sources.list
apt-get update
apt-get upgrade -y
apt-get install -y dpkg-dev debhelper libarchive-dev libdb-dev libbz2-dev libgpgme11-dev liblzma-dev libz-dev
apt-get source reprepro
sed -i 's/libgpgme-dev/libgpgme11-dev/' reprepro-5.1.1/debian/control
cd reprepro-5.1.1
dpkg-buildpackage -rfakeroot -uc -b
