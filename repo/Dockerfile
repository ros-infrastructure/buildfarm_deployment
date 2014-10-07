FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby

# Optimization, will be asserted by puppet
RUN apt-get install -y apache2 reprepro

# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates

RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install jtopjian-reprepro
RUN puppet module install puppetlabs-apache

ADD manifests /tmp/manifests

RUN puppet apply -v /tmp/manifests/site.pp

CMD bash -c 'echo "hello world" && while true; do sleep 1; done'
