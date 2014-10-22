import 'slave.pp'


## required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}


### install latest docker

package { 'apt-transport-https':
  ensure => 'installed',
}

apt::source { 'docker':
  location => 'https://get.docker.com/ubuntu',
  release => 'docker',
  repos => 'main',
  key => 'A88D21E9',
  key_server => 'keyserver.ubuntu.com',
  include_src => false,
  require => Package['apt-transport-https'],
}

package { 'lxc-docker':
  ensure => 'installed',
  require => Apt::Source['docker'],
}

# change docker storage driver
file { '/etc/default/docker':
    mode => '0644',
    owner => root,
    group => root,
    source => 'puppet:///modules/slave_files/etc/default/docker',
    require => Package['lxc-docker'],
}
