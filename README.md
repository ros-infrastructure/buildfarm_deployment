buildfarm_deployment
====================





Manual Deployment
=================

You will need a fork of this repo where you will customize the contents of */common.yaml

Specifically you will need to update:
master::ip
repo::ip
master


Master
------

Memory 30Gb
200GB disk space

recommend r3.xlarge

Slave
-----

Provision a machine with 200+ GB hard disk
recommend c3.large or faster

Repo
----

Provision 100Gb disk space

recommend t2.medium

Setup
-----

Record all their IPs set it up

Fork buildfarm_deployment set the IPs in common.yaml and commit
  * `master::ip:`
  * `repo::ip:`

If you're on ec2 these can be the internal IPs to save bandwidth consumption.



Master Setup
------------

Log in:

```
sudo su root
cd
apt-get update
apt-get install -y git

# Customize this URL for your fork
git clone https://github.com/ros-infrastructure/buildfarm_deployment.git
cd buildfarm_deployment/master/
./install_prerequisites.bash
./deploy.bash
```

Repo Setup
----------

Log in:

```
sudo su root
cd
apt-get update
apt-get install -y git

# Customize this URL for your fork
git clone https://github.com/ros-infrastructure/buildfarm_deployment.git
cd buildfarm_deployment/repo/
./install_prerequisites.bash
./deploy.bash
```

Slave Setup
-----------

Log in:

```
sudo su root
cd
apt-get update
apt-get install -y git

# Customize this URL for your fork
git clone https://github.com/ros-infrastructure/buildfarm_deployment.git
cd buildfarm_deployment/slave/
./install_prerequisites.bash
./deploy.bash
```

Multiple Slaves
,,,,,,,,,,,,,,,

You can add as many slaves as you want to a running master.
They will automatically contact the master and add themselves.

Security Notes
--------------

This repo comes with credentials they are publicly available and not secure!

For a deployment you will need to change all of them and make your repo private.

The above documentation does not cover changing any of the credentials, or authorizing access to a private repository.
More information will be made available in future drafts.


How to use the new machines
---------------------------

Now that you have a running system you will need to add jobs for one or more rosdistros.
See the [ros_buildfarm repo](https://github.com/ros-infrastructure/ros_buildfarm) for more info.



Local testing in Docker
=======================

For development a quick way to test is to run a local docker instance of each type of machine.
The following are instructions for setting these elements.

Change docker storage driver
----------------------------

Edit `/etc/default/docker` and add the following line:

    DOCKER_OPTS="--bip=172.17.42.1/16 --dns=172.17.42.1 --dns 8.8.8.8 --dns-search dev.docker --storage-driver=devicemapper"

DNS via skydns
--------------

DNS lookup will be made avaialable from the default dns above by skydock in the dev.docker domain.
The hostname format is IMAGE.dev.docker or IMAGENAME.IMAGE.dev.docker if there are more than one.

To launch:

```
docker build -t slave slave/
docker build -t master master/
docker build -t repo repo/

fig up
```
