FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby
# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates
RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins

ADD manifests /tmp/manifests
ADD slave_files /tmp/manifests/slave_files

ADD hiera.yaml /etc/puppet/hiera.yaml
RUN mkdir -p /etc/puppet/hieradata
ADD common.yaml /etc/puppet/hieradata/common.yaml

RUN puppet apply -v /tmp/manifests/site.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:/tmp/manifests

RUN adduser jenkins-slave docker
VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
CMD bash -c '/etc/init.d/jenkins-slave start && dmsetup mknodes && /home/jenkins-slave/wrapdocker && while true; do sleep 1; done'
