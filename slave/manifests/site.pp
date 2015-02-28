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
    notify => Service['jenkins-slave'],
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

class { 'jenkins::slave':
  labels => 'buildslave',
  slave_mode => 'exclusive',
  slave_user => 'jenkins-slave',
  manage_slave_user => false,
  executors => hiera('jenkins::slave::num_executors', 1),
  require => User['jenkins-slave'],
}

user{'jenkins-slave':
  ensure => present,
  managehome => true,
  groups => ['docker'],
  require => Package['lxc-docker']
}

# required by cleanup_docker_images.py
package { 'python3-dateutil':
  ensure => 'installed',
}

## required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}

# required by subprocess reaper script
package { 'python3-psutil':
  ensure => 'installed',
}

# For jenkins-slave instance checkouts
package { 'bzr':
  ensure => 'installed',
}

package { 'git':
  ensure => 'installed',
}

package { 'mercurial':
  ensure => 'installed',
}

# required for armhf builds
package { 'qemu-user-static':
  ensure => 'installed',
}

package { 'subversion':
  ensure => 'installed',
}

# setup ntp with defaults
include '::ntp'

### install latest docker

class {'docker':
}

package { 'python3-pip':
 ensure => 'installed',
}

# required by cleanup_docker script
pip::install { 'docker-py':
  #package => 'jenkinsapi', # defaults to $title
  #version => '1.6', # if undef installs latest version
  python_version => '3', # defaults to 2.7
  #ensure => present, # defaults to present
  require => Package['python3-pip'],
}

# script to clean up docker images from oldest
file { '/home/jenkins-slave/cleanup_docker_images.py':
  mode => '0774',
  owner => 'jenkins-slave',
  group => 'jenkins-slave',
  source => 'puppet:///modules/slave_files/home/jenkins-slave/cleanup_docker_images.py',
  require => User['jenkins-slave'],
}

if hiera('run_squid', false) {
  #docker::image {'jpetazzo/squid-in-a-can':
  # switched to fork pending merge of pr https://github.com/jpetazzo/squid-in-a-can/pull/11
  docker::image {'tfoote/squid-in-a-can_pr_11':
    require => Package['docker'],
  }

  file { '/var/cache/squid-in-a-can' :
    ensure => 'directory',
    mode   => 644,
    owner  => 'proxy',
    group  => 'proxy',
  }

  docker::run {'squid-in-a-can':
    image   => 'tfoote/squid-in-a-can_pr_11',
    command => '/tmp/deploy_squid.py',
    env     => ['DISK_CACHE_SIZE=5000', 'MAX_CACHE_OBJECT=1000', 'SQUID_DIRECTIVES=\'
refresh_pattern . 0 0 1 refresh-ims
refresh_all_ims on # make sure we do not get out of date content #41
ignore_expect_100 on # needed for new relic system monitor
\''],
    volumes => ['/var/cache/squid-in-a-can:/var/cache/squid3'],
    net     => 'host',
    require => [Docker::Image['tfoote/squid-in-a-can_pr_11'],
                File['/var/cache/squid-in-a-can'],
               ],
  }

  class { 'iptables':
    config => 'file', # This is needed to activate file mode
    source => [ "puppet:///modules/slave_files/etc/iptables.docker_squid"],
  }
}
else {
  class { 'iptables':
    config => 'file', # This is needed to activate file mode
    source => [ "puppet:///modules/slave_files/etc/iptables.docker"],
  }

}
if hiera('autoreconfigure') {
  cron {'autoreconfigure':
    environment => ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
  '],
    command => hiera('autoreconfigure::command'),
    user    => root,
    month   => absent,
    monthday => absent,
    hour    => absent,
    minute  => '*/15',
    weekday => absent,
  }
}
else {
  cron {'autoreconfigure':
    ensure => absent,
  }
}

# leave this in to clean up autoreconfigured machines #2015-02-02
cron {'docker_cleanup_containers':
  ensure => absent,
  user    => 'jenkins-slave',
}

# clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
cron {'docker_cleanup_images':
  command => 'bash -c "python3 -u /home/jenkins-slave/cleanup_docker_images.py --minimum-free-percent 10 --minimum-free-space 50"',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/2',
  minute  => 15,
  weekday => absent,
  require => User['jenkins-slave'],
}
