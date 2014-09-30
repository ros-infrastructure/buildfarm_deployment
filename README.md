buildfarm_deployment
====================


Deploy test jenkins master:
---------------------------

cd jenkins
docker build -t master_image .
docker run -p 0.0.0.0:8080:8080 -t -i --name master master_image


Deploy a jenkins slave
----------------------

cd jenkins/slave
docker build -t slave .
docker run -t -i --link master:master slave
