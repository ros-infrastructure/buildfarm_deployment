buildfarm_deployment
====================

Change docker storage driver
----------------------------

Edit `/etc/default/docker` and add the following line:

    DOCKER_OPTS="--bip=172.17.42.1/16 --dns=172.17.42.1 --dns 8.8.8.8 --storage-driver=devicemapper"

DNS via skydns
--------------

DNS lookup will be made avaialable from the default dns above by skydock in the dev.docker domain. 
The hostname format is IMAGE.dev.docker or IMAGENAME.IMAGE.dev.docker if there are more than one. 


Deploy test jenkins master:
---------------------------

To start the master locall

    cd jenkins
    docker build -t master_image .
    docker run -p 0.0.0.0:8080:8080 -t -i --name master master_image

to run another instance you will need to remove the labeled container

    docker rm master


Deploy a jenkins slave
----------------------

Start a slave like this, linking to the local master

    cd jenkins/slave
    docker build -t slave .
    docker run -t -i --link master:master slave
