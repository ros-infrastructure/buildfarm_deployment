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
ADD hiera.yaml /etc/puppet/hiera.yaml
RUN mkdir -p /etc/puppet/hieradata
ADD common.yaml /etc/puppet/hieradata/common.yaml

RUN puppet apply -v /tmp/manifests/site.pp

RUN adduser jenkins-slave docker

CMD bash -c 'service docker.io start && /etc/init.d/jenkins-slave start && while true; do sleep 1; done'
