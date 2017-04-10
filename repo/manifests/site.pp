# bring in classes listed in hiera
if hiera('classes', false) {
  hiera_include('classes')
}


# Find the other instances
if hiera('master::ip', false) {
  host {'master':
    ip => hiera('master::ip'),
  }
}
else {
  host {'master':
    ensure => absent,
  }
}

# Setup generic ssh_keys
if hiera('ssh_keys', false){
  $defaults = {
    'ensure' => 'present',
  }
  create_resources(ssh_authorized_key, hiera('ssh_keys'), $defaults)
}
else{
  notice("No ssh_keys defined. You need at least one for jenkins-agent.")
}

include profile::osrf::base
include profile::osrf::repo
