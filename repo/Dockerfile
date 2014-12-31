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

ADD . /root/buildfarm_deployment/repo

WORKDIR /root/buildfarm_deployment/repo
RUN /root/buildfarm_deployment/repo/install_prerequisites.bash
RUN /root/buildfarm_deployment/repo/deploy.bash

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

VOLUME /var/lib/docker
CMD bash -c 'service ntp start && service ssh start && service apache2 start && /etc/init.d/jenkins-slave start && /home/jenkins-slave/wrapdocker && while true; do sleep 1; done'
