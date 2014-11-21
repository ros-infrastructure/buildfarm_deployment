FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby
# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates
RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install tracywebtech-pip
RUN puppet module install puppetlabs-ntp

# installing here to leverage docker caching (will be enforced by puppet later)
RUN apt-get install -y curl python3-pip python3-yaml python3-empy apt-transport-https bzr mercurial

RUN mkdir -p /tmp/jenkins
ADD manifests /tmp/jenkins/manifests
ADD jenkins_files /tmp/jenkins/jenkins_files

ADD hiera.yaml /etc/puppet/hiera.yaml
RUN mkdir -p /etc/puppet/hieradata
ADD common.yaml /etc/puppet/hieradata/common.yaml

WORKDIR /tmp/jenkins
RUN puppet apply -v /tmp/jenkins/manifests/init.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:/tmp/jenkins
EXPOSE 8080

VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
CMD bash -c 'service ntp start && service jenkins start && dmsetup mknodes && /var/lib/jenkins/wrapdocker && while true; do sleep 1; done'
