## Overview

For an overview about the ROS build farm including how to deploy the necessary
machine see the [ROS buildfarm wiki page](http://wiki.ros.org/buildfarm).


This repository implementation for deploying servers for the ROS buildfarm.
It typically requires the configurations given as an example in  [buildfarm_deployment_config](https://github.com/ros-infrastructure/buildfarm_deployment_config).

After the servers have been provisioned you will then want to see the [ros_buildfarm](https://github.com/ros-infrastructure/ros_buildfarm) project for how to configure Jenkins with ROS jobs.

### Process

To effectively use this there will be three main steps.
* Provision the hardware/VM instances.
* Fork this repository and update the configuration.
* Deploy the forked configuration onto the machines.

At the end of this process you will have a Jenkins master, a package repository, and N jenkins-slaves.

## Provisioning

The following EC2 instance types are recommended when deploying to Amazon EC2.
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

## Forking (or not)

The config repository will contain your secrets such as private keys and access tokens.
You should make a copy of the config repository and make it private.
Unfortunately you can't use the "Fork" button on GitHub and then make it private.

To create a private fork.

1. Create a new empty private repo
1. Push from a clone of the public repo into the private repo.

### Access

To give access to your private repo you will need to authenticate.

The below example has setup the config repo with token access.
And embedded the token in the below URLs.
Keep this token secret!

### Updating values

It is recommended to change all the security parameters from this configuration.
In particular you should change the following:

On all three:
* `jenkins::slave::ui_pass`
* This is the passworkd for the slave to access the master
* `user::admin::password_hash`
* On the master this should be the hashed password from above
* The easiest way to create this is to setup a jenkins instance. Change the password, then copy the string out of config file on the jenkins server.
* `autoreconfigure::branch`
* If you are forking into a repo and using a different branch name, update the autoreconfigure command to point to the right branch.

On repo:
* `jenkins-slave::authorized_keys`
* This is the string contents for the authorized keys for the slaves to push into the repo. (It should match the `jenkins::private_ssh_key` on the master.
  * `jenkins-slave::gpg_public_key`
  * The GPG public key matching the private key. This will be made available for download from the repo for verification.
  * `jenkins-slave::gpg_private_key`
  * The GPG key with which to sign the repository.
  * `master::ip`
  * The IP address of the master instance.

  On the master:
  * `jenkins::authorized_keys`
  * This is the string contents for the authorized keys for the slaves to push into the repo. (It should match the `jenkins::private_ssh_key` on the master.
    * `jenkins::private_ssh_key`
    * The key which authorizes access to push content into the repository or to connect back to the master from a job.
    * `master::ip`
    * The IP address of the master instance.
    * `repo::ip`
    * The IP address of the repository instance.

    On the slave:
    * `master::ip`
    * The IP address of the master instance.
    * `repo::ip`
    * The IP address of the repository instance.
    * `jenkins::slave::num_executors`
     * The number of executors to instantiate on each slave.
       From current testing you can do one per available core, as long as at least 2GB of memory are available for each executor.


## Deployment

Once you have customized all the content of the config repo on each provisioned machine run the following sequence of commands.

### Master deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./install_prerequisites.bash
    ./reconfigure.bash master


### repo deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./install_prerequisites.bash
    ./reconfigure.bash repo

### slave deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./install_prerequisites.bash
    ./reconfigure.bash slave

## After Deployment

Now that you have a running system you will need to add jobs for one or more rosdistros.
See the [ros_buildfarm repo](https://github.com/ros-infrastructure/ros_buildfarm) for more info.

# For information on development and testing

See [doc/DevelopmentTesting.md](doc/DevelopmentTesting.md)
