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

### Building the images

To build the images:

```bash
python build.py
```

### Running the images:
```bash
fig up
```

### Accessing the local images

This will expose the master as http://localhost:8080 and the repo at http://localhost:8081
