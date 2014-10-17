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

ADD . /tmp/jenkins

WORKDIR /tmp/jenkins
RUN puppet apply -v /tmp/jenkins/manifests/init.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:/tmp/jenkins
EXPOSE 8080
CMD bash -c 'service docker start && service jenkins start && while true; do sleep 1; done'
