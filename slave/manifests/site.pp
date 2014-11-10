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

# use wrapdocker from dind
file { '/home/jenkins-slave/wrapdocker':
    mode => '0774',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    source => 'puppet:///modules/slave_files/home/jenkins-slave/wrapdocker',
    require => User['jenkins-slave'],
}

## wrapdocker requires apparmor to avoid this error:
# Error loading docker apparmor profile: fork/exec /sbin/apparmor_parser: no such file or directory ()
# https://github.com/docker/docker/issues/4734
package { 'apparmor':
  ensure => 'installed',
}
