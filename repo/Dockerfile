FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby

# Optimization, will be asserted by puppet
RUN apt-get install -y apache2 reprepro

# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates
RUN apt-get install -y openssh-server apparmor python-yaml daemon python-configparser

RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install puppetlabs-apache
RUN puppet module install puppetlabs-vcsrepo
RUN puppet module install puppetlabs-ntp

ADD . /tmp/buildfarm_deployment/repo

WORKDIR /tmp/buildfarm_deployment/repo
RUN /tmp/buildfarm_deployment/repo/install_prerequisites.bash
RUN /tmp/buildfarm_deployment/repo/deploy.bash

USER jenkins-slave
WORKDIR /home/jenkins-slave/reprepro-updater
ENV PYTHONPATH /home/jenkins-slave/reprepro-updater/src:$PYTHONPATH
# Setup reprepro repos
RUN python ./scripts/setup_repo.py ubuntu_building -c
RUN python ./scripts/setup_repo.py ubuntu_testing -c
RUN python ./scripts/setup_repo.py ubuntu_main -c

USER root
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

VOLUME /var/lib/docker

CMD bash -c 'service ntp start && service ssh start && service apache2 start && /etc/init.d/jenkins-slave start && while true; do sleep 1; done'
