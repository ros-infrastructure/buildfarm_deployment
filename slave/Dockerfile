FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby
# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates apparmor apt-transport-https python3-empy

RUN apt-get update
RUN apt-get install -y bzr mercurial subversion
RUN apt-get install -y ntp

RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install puppetlabs-ntp

ADD . /tmp/buildfarm_deployment/slave

WORKDIR /tmp/buildfarm_deployment/slave
RUN /tmp/buildfarm_deployment/slave/deploy.bash

VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
CMD bash -c 'service ntp start && /etc/init.d/jenkins-slave start && dmsetup mknodes && /home/jenkins-slave/wrapdocker && while true; do sleep 1; done'
