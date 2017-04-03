include profile::osrf::base
include profile::jenkins::master

if hiera('classes', false) {
  hiera_include('classes')
}

# Needed by jenkins-slave to connect to the local master generically
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
