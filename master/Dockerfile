FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby
# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates
# installing here to leverage docker caching (will be enforced by puppet later)
RUN apt-get install -y curl python3-pip python3-yaml python3-empy apt-transport-https bzr mercurial

RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install tracywebtech-pip
RUN puppet module install puppetlabs-ntp


ADD . /tmp/buildfarm_deployment/master

WORKDIR /tmp/buildfarm_deployment/master
RUN /tmp/buildfarm_deployment/master/install_prerequisites.bash
RUN /tmp/buildfarm_deployment/master/deploy.bash

EXPOSE 8080

VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
CMD bash -c 'service ntp start && service jenkins start && dmsetup mknodes && /var/lib/jenkins/wrapdocker && while true; do sleep 1; done'
