#!/bin/bash

set -o errexit

cp hiera.yaml /etc/puppet
mkdir -p /etc/puppet/hieradata
cp common.yaml /etc/puppet/hieradata

puppet apply -v manifests/site.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:`pwd` -l /var/log/puppet.log
