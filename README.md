## Overview

For an overview about the ROS build farm including how to deploy the necessary
machine see the [ROS buildfarm wiki page](http://wiki.ros.org/buildfarm).


This repository implementation for deploying servers for the ROS buildfarm.
It typically requires the configurations given as an example in  [buildfarm_deployment_config](https://github.com/ros-infrastructure/buildfarm_deployment_config).

After the servers have been provisioned you will then want to see the [ros_buildfarm](https://github.com/ros-infrastructure/ros_buildfarm) project for how to configure Jenkins with ROS jobs.

If you are going to use any of the provided infrastructure please consider
signing up for the build farm mailing list
(https://groups.google.com/d/forum/ros-sig-buildfarm) in order to receive
notifications e.g. about any upcoming changes.

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

**The config repository will contain your secrets such as private keys and access tokens, keep it private!**
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
* This is the password for the slave to access the master
 * `user::admin::password_hash`
* On the master this should be the hashed password from above
 * The easiest way to create this is to setup a jenkins instance.
   Change the password, then copy the string out of config file on the jenkins server.
* `autoreconfigure::branch`
* If you are forking into a repo and using a different branch name, update the autoreconfigure command to point to the right branch.
* `ssh_keys`
 * Configure as many public ssh-keys as you want for administrators to log in.
   It's recommended at least one for root.
 * On the repo machine make sure there is at least one key for the jenkins-slave user matching the ssh private key
  `jenkins::private_key` provisioned on the master.

::

    ssh_keys:
        'admin@foobar':
            ensure: present
            key: AAAAB3NzaC1yc2EAAAADAQABAAABAQC2NOaRsdZqqTrCwNR77AQIqwAPYkDfiL1Ou7Pi/qaW9S7UU0Y1KAQ6kWhgJc9RtOhbZKGHbFTqSLT4235TkmPvlZbV2bK8ZViBmqQ3r8vDMhC/+p9Ec9SP8sjv6JcIEWOy5zXPnB3OnHHWXmvZP47rjJY0l76F71fZt3vlvyjz7IrikULmuKcyrE+zulmbSTtfGZhxQRPxZDO/RiOemCPsYo5u/rUMjWH+CkEI0swQlM6QIvjWdfYtNwQT9yo53MXFy5jodhW4YOOncKE4RMOI9Lmu6jE0GmdmSEv486R4ot6iWanx2hk/46zlmX1kSKGWObRdH57H/xIAxvw+PiTd
            type: ssh-rsa
            user: root
        'upload_access@buildfarm':
            ensure: present
            key: AAAAB3NzaC1yc2EAAAADAQABAAABAQC2NOaRsdZqqTrCwNR77AQIqwAPYkDfiL1Ou7Pi/qaW9S7UU0Y1KAQ6kWhgJc9RtOhbZKGHbFTqSLT4235TkmPvlZbV2bK8ZViBmqQ3r8vDMhC/+p9Ec9SP8sjv6JcIEWOy5zXPnB3OnHHWXmvZP47rjJY0l76F71fZt3vlvyjz7IrikULmuKcyrE+zulmbSTtfGZhxQRPxZDO/RiOemCPsYo5u/rUMjWH+CkEI0swQlM6QIvjWdfYtNwQT9yo53MXFy5jodhW4YOOncKE4RMOI9Lmu6jE0GmdmSEv486R4ot6iWanx2hk/46zlmX1kSKGWObRdH57H/xIAxvw+PiTd
            type: ssh-rsa
            user: jenkins-slave

On repo:
  * `jenkins-slave::gpg_public_key`
  * The GPG public key matching the private key.
    This will be made available for download from the repo for verification.
  * `jenkins-slave::gpg_private_key`
  * The GPG key with which to sign the repository.
  * `master::ip`
  * The IP address of the master instance.
  * `jenkins-slave::reprepro_config`
   * Fill in the correct rules for upstream imports.
     It should be a hash/dict item with the filename as the key, ensure, and content as elements like below.
     You can have as many elements as you want for different files.


          jenkins-slave::reprepro_config:
              '/home/jenkins-slave/reprepro_config/empy_saucy.yaml':
                  ensure: 'present'
                  content: |
                      name: empy_saucy
                      method: http://packages.osrfoundation.org/gazebo/ubuntu
                      suites: [saucy]
                      component: main
                      architectures: [i386, amd64, source]
                      filter_formula: Package (% python3-empy)


On the master:
  * `jenkins::private_ssh_key`
  * The ssh private key  will be provisioned as an ssh-credential available via the ssh-agent inside a jenkins jobs.
    This is necessary for access to push content onto the repo machine.
    It can also be used to access other machines from within the job execution environment.
    This will require deploying the matching public key to the other machines appropriately.
    **Note: This value should be kept secret!**
  * `master::ip`
  * The IP address of the master instance.
  * `repo::ip`
  * The IP address of the repository instance.

  * `credentials::jenkins-slave::username`
  * The name of the credentials
  * `credentials::jenkins-slave::id`
  * A UUID for the credentials in thef format `1e7d4696-7fd4-4bc6-8c87-ebc7b6ce16e5`
  * `credentials::jenkins-slave::passphrase`
  * The hashed passphrase for the key. The UI puts this has in if there's now passphrase `4lRsx/NwfEndwUlcWOOnYg== `
   * If you would like to modify these values from the default it will likely be easiest to boot an instance. Change the credentials via the UI, then grab the values out of the config file.

  * If you would like to be able to clone source and release repositories over git+ssh, add the `git-fetch-ssh` credential by setting the following optional parameters:
    * `credentials::git-fetch-ssh::username`
    * The name of the credentials
    * `credentials::git-fetch-ssh::id`
    * A UUID for the credentials in the format `1e7d4696-7fd4-4bc6-8c87-ebc7b6ce16e5`
    * `credentials::git-fetch-ssh::passphrase`
    * The hashed passphrase for the key. The UI puts this hash in if there's no passphrase: `4lRsx/NwfEndwUlcWOOnYg== `
    * `credentials::git-fetch-ssh::private_key`
    * An SSH private key that has access to the source and release repositories that the buildfarm will use.


On the slave:
* `master::ip`
* The IP address of the master instance.
* `repo::ip`
* The IP address of the repository instance.
* `jenkins::slave::num_executors`
 * The number of executors to instantiate on each slave.
   From current testing you can do one per available core, as long as at least 2GB of memory are available for each executor.
* `ssh_host_keys`
* Required for uploading to doc job results. You will need to add the host verification for both the name and IP of the repo server. 
* If you would like to clone source and release repositories over git+ssh, set the host keys for the servers that will be used in the `ssh_host_keys` parameter. This parameter is a dictionary mapping server names to host keys. Host keys can be discovered with the `ssh-keyscan -H <hostname>` command.
````
ssh_host_keys:
ssh_host_keys:
    repo: |
        repo ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFc/Nq1TAnCl4XC4nFl6QNOLcJLw5vY0lkvMlVULn8jkQPn3iUy59Q2fja+h4lmQlD17iSY3o4luHUYkYKAdHcI=
    54.183.65.232: |
        54.183.65.232 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFc/Nq1TAnCl4XC4nFl6QNOLcJLw5vY0lkvMlVULn8jkQPn3iUy59Q2fja+h4lmQlD17iSY3o4luHUYkYKAdHcI=
    'github.com': |
        |1|/F/a+D+AA/y+qf7+IMSwXbvfFZo=|Pygbd2OeNdWzbgAyZK/kwEet9u0= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    'bitbucket.org': |
        |1|VoTP5i1zOk28A+ELJ0XpcMdpiBc=|Y61MET377AK92/9wJzCZhQMoGmw= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==
````

## Deployment

Once you have customized all the content of the config repo on each provisioned machine run the following sequence of commands.

### Master deployment

    sudo su
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./install_prerequisites.bash
    ./reconfigure.bash master


### repo deployment

    sudo su
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./install_prerequisites.bash
    ./reconfigure.bash repo

### slave deployment

    sudo su
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

### Setup Master for Email Delivery

Jenkins is most powerful when you set it up for email notifications.
By default we have not provisioned how to send emails, which means that non will be sent.
Jenkins will attempt to send via a local mail trainsfer agent(MTA), if SMTP is not configured.
You can install postfix or sendmail to provide a local MTA.
If you do setup a local MTA, make sure that you provide proper reverse DNS lookups for your server.
And it's also highly recommended to make sure to add SPF entries for your server to make sure that the automated emails are not caught in the spam filter.

When you enable email for your server, make sure to update the administrator email address.
It can be found in the main configuration, `Manage Jenkins -> Configure Jenkins -> System Admin e-mail address`.
Our values is 'ROS Buildfarm <noreploy@build.ros.org>' This will be the return address for the automated emails.

Instead of setting up an MTA you can also use an external SMTP server.
To use this in `Manage Jenkins -> Configure Jenkins` you will find `Extended E-mail Notification` and `E-mail Notification` both of which you should fill out with your SMTP server's credentials.

# For information on development and testing

See [doc/DevelopmentTesting.md](doc/DevelopmentTesting.md)
