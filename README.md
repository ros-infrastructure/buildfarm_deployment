buildfarm_deployment
====================


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
