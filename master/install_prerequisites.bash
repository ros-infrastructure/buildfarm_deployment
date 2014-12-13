#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby
gem install puppet --no-rdoc --no-ri
puppet module install garethr-docker
puppet module install puppetlabs-ntp
puppet module install rtyler/jenkins
puppet module install tracywebtech-pip
