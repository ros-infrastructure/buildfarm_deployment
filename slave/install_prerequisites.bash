#!/bin/bash

apt-get update
apt-get install ruby

# not explicitly called out by jenkins-slave but needed
apt-get install -y bzr git mercurial subversion

gem install puppet --no-rdoc --no-ri
puppet module install rtyler/jenkins
puppet module install puppetlabs-ntp
