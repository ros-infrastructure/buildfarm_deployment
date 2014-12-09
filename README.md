# buildfarm_deployment



# Deployment Guide

This project supports two modes of deployment by default (see following sections for details):

* Deployment to **multiple separate (virtual or physical) machines**<br/>
  (e.g. on Amazon EC2 or your preferred virtual machine environment).

* Deployment as **multiple Docker containers**.

# Deploying to virtual machines

You will need a fork of this repo where you will customize the contents of `*/common.yaml`.

Specifically you will need to update:
  * `master::ip`
  * `repo::ip`
  * `master`

## Recommended System Requirements for Production

The following EC2 instance types are recommended when deploying to Amazon EC2.<br/>
They are intended as a guideline for choosing the appropriate parameters when deploying to other platforms.

### Master

<table>
<tr><td>Memory</td><td>30Gb</td></tr>
<tr><td>Disk space</td><td>200Gb</td></tr>
<tr><td><strong>Recommendation</strong></td><td>r3.xlarge</td></tr>
</table>

### Slave

<table>
<tr><td>Disk space</td><td>200Gb+</td></tr>
<tr><td><strong>Recommendation</strong></td><td>c3.large or faster</td></tr>
</table>

### Repo

<table>
<tr><td>Disk space</td><td>100Gb</td></tr>
<tr><td><strong>Recommendation</strong></td><td>t2.medium</td></tr>
</table>

## Setup

Record all their IPs set it up

Fork buildfarm_deployment set the IPs in common.yaml and commit
  * `master::ip:`
  * `repo::ip:`

If you're on EC2 these can be the internal IPs to save bandwidth consumption.



### Master Setup

Log in:

```bash
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

### Repo Setup

Log in:

```bash
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

### Slave Setup

Log in:

```bash
sudo su root
cd
apt-get update
apt-get install -y git btrfs-tools

#Assuming a large device is available at /dev/vdb
mkfs.btrfs /dev/vdb -f
echo "/dev/vdb /var/lib/docker auto    defaults,nobootwait,comment=cloudconfig 0   2">> /etc/fstab
mkdir /var/lib/docker
mount /var/lib/docker


git clone https://github.com/ros-infrastructure/buildfarm_deployment.git -b ec2test_btrfs
cd buildfarm_deployment/slave/
./install_prerequisites.bash
./deploy.bash
```

#### Multiple Slaves

You can add as many slaves as you want to a running master.
They will automatically contact the master and add themselves.

## Security Notes

This repo comes with credentials they are publicly available and not secure!

For a deployment you will need to change all of them and make your repo private.

The above documentation does not cover changing any of the credentials, or authorizing access to a private repository.
More information will be made available in future drafts.

You should change:

The admin password

On all three:
 * `jenkins::slave::ui_pass`
 * on the master this should be the hashed password from above `user::admin::password_hash`
 * If you don't use the master branch on all machines change: `autoreconfigure::branch`


 On repo:
 * `jenkins-slave::authorized_keys`
 * `jenkins-slave::gpg_public_key`
 * `jenkins-slave::gpg_private_key`


 On the master:
  * `jenkins::authorized_keys`
  * `jenkins::private_ssh_key`


## How to use the new machines

Now that you have a running system you will need to add jobs for one or more rosdistros.
See the [ros_buildfarm repo](https://github.com/ros-infrastructure/ros_buildfarm) for more info.



# Local testing in Docker

For development a quick way to test is to run a local docker instance of each type of machine.
The following are instructions for setting up these elements.

## Change docker storage driver

Edit `/etc/default/docker` and add the following line:

    DOCKER_OPTS="--bip=172.17.42.1/16 --dns=172.17.42.1 --dns 8.8.8.8 --dns-search dev.docker --storage-driver=devicemapper"

## DNS via skydns

DNS lookup will be made available from the default dns above through [skydock](https://github.com/crosbymichael/skydock) in the `dev.docker` domain.
The hostname format is `IMAGE.dev.docker` or `CONTAINER.IMAGE.dev.docker` if there are multiple containers with the same image.

To launch:

```bash
./build_all.bash

fig up
```
