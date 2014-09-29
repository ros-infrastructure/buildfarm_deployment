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

RUN puppet apply -v /tmp/manifests/init.pp
EXPOSE 8080
CMD service jenkins start && bash