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
#RUN puppet module install jtopjian-reprepro
#RUN puppet module install tfoote-reprepro
RUN puppet module install puppetlabs-apache
RUN puppet module install puppetlabs-vcsrepo

ADD manifests /tmp/manifests
ADD hiera.yaml /etc/puppet/hiera.yaml
RUN mkdir -p /etc/puppet/hieradata
ADD common.yaml /etc/puppet/hieradata/common.yaml
RUN puppet apply -v /tmp/manifests/site.pp

WORKDIR /tmp
USER jenkins-slave
WORKDIR /tmp/reprepro-updater
ENV PYTHONPATH /tmp/reprepro-updater/src:$PYTHONPATH
# Setup reprepro repos
RUN python ./scripts/setup_repo.py /var/repos/ubuntu/building -c
RUN python ./scripts/setup_repo.py /var/repos/ubuntu/testing -c
RUN python ./scripts/setup_repo.py /var/repos/ubuntu/main -c

RUN python ./scripts/import_upstream.py /var/repos/ubuntu/building /tmp/reprepro-updater/config/bootstrap.yaml -c
RUN python ./scripts/import_upstream.py /var/repos/ubuntu/testing /tmp/reprepro-updater/config/bootstrap.yaml -c
RUN python ./scripts/import_upstream.py /var/repos/ubuntu/main /tmp/reprepro-updater/config/bootstrap.yaml -c

USER root

CMD bash -c 'service apache2 start && /etc/init.d/jenkins-slave start && while true; do sleep 1; done'
