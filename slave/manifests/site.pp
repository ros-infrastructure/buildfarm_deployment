# Find the other instances
if hiera('repo::ip', false) {
  host {'repo':
    ip => hiera('repo::ip'),
  }
}
else {
  host {'repo':
    ensure => absent,
  }
}

if hiera('master::ip', false) {
  host {'master':
    ip => hiera('master::ip'),
    notify => Service['jenkins-agent'],
  }
}
else {
  host {'master':
    ensure => absent,
  }
}

# bring in classes listed in hiera
if hiera('classes', false) {
  hiera_include('classes')
}

# Setup generic ssh_keys
if hiera('ssh_keys', false){
  $defaults = {
    'ensure' => 'present',
  }
  create_resources(ssh_authorized_key, hiera('ssh_keys'), $defaults)
}
else{
  notice("No ssh_keys defined. You should probably have at least one.")
}

include profile::osrf::base
include profile::jenkins::agent

if hiera('run_squid', false) {
  include profile::squidinacan
}
