## Docker based local testing

For development a quick way to test is to run a local docker instance of each type of machine.
The following are instructions for setting up these elements.

### Change docker storage driver

Edit `/etc/default/docker` and add the following line:

DOCKER_OPTS="--bip=172.17.42.1/16 --dns=172.17.42.1 --dns 8.8.8.8 --dns-search dev.docker --storage-driver=devicemapper"

### DNS via skydns

DNS lookup will be made available from the default dns above through [skydock](https://github.com/crosbymichael/skydock) in the `dev.docker` domain.
The hostname format is `IMAGE.dev.docker` or `CONTAINER.IMAGE.dev.docker` if there are multiple containers with the same image.

NOTE: For this to work `master::io`, `repo::ip`, and `slave::ip` must all be commented out in all `common.yaml` files.
And the images for the master and repo must be named `master` and `repo` for the DNS lookup to work



## Checkout the [buildfarm_deployment_config example repo](https://github.com/ros-infrastructure/buildfarm_deployment_config)

```bash
git clone https://github.com/ros-infrastructure/buildfarm_deployment_config.git
```

### Enter the directory

Change your working directory into the checkout

```bash
cd buildfarm_deployment_config
```

### Building the images

To build the images:

```bash
cd buildfarm_deployment_config
python build.py
```

### Running the images:
```bash
fig up
```

### Accessing the local images

This will expose the master as http://localhost:8080 and the repo at http://localhost:8081


## Kicking off jobs inside docker

Once you have the farm up you will need to configure it using [ros_buildfarm](https://github.com/ros-infrastructure/ros_buildfarm).

You can get access to the docker machines by ip.
But for convenience there's a helper docker image you can use to configure the buildfarm inside docker, [buildfarm_inprogress_helpers]](http://github.com/tfoote/buildfarm_inprogress_helpers)
