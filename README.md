buildfarm_deployment
====================

Change docker storage driver
----------------------------

Edit `/etc/default/docker` and add the following line:

    DOCKER_OPTS="--bip=172.17.42.1/16 --dns=172.17.42.1 --dns 8.8.8.8 --dns-search dev.docker --storage-driver=devicemapper"

DNS via skydns
--------------

DNS lookup will be made avaialable from the default dns above by skydock in the dev.docker domain.
The hostname format is IMAGE.dev.docker or IMAGENAME.IMAGE.dev.docker if there are more than one.

To launch:

cd slave && docker build -t slave .
cd master && docker build -t master .
cd repo && docker build -t repo .

fig up
