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

class { 'jenkins::slave':
  labels => 'buildslave',
  slave_mode => 'exclusive',
  slave_user => 'jenkins-slave',
  manage_slave_user => '1',
  executors => '1',
}


exec {"jenkins-slave docker membership":
  path    => '/usr/sbin:/usr/bin:/sbin:/bin',
  unless => "grep -q 'docker\\S*jenkins-slave' /etc/group",
  command => "usermod -aG docker jenkins-slave",
  require => User['jenkins-slave'],
}

## required by jobs to generate Dockerfiles
package { 'python3-empy':
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

package { 'subversion':
  ensure => 'installed',
}

# setup ntp with defaults
include '::ntp'

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

if hiera('autoreconfigure') {
  $autoreconf_key = 'AUTORECONFIGURE_UPSTREAM_BRANCH='
  $branch_str = hiera('autoreconfigure::branch')
  $env_str = "$autoreconf_key$branch_str"
  cron {'autoreconfigure':
    environment => [$env_str,
                    'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
'],
    command => 'bash -c "cd /root/buildfarm_deployment && git fetch origin && git reset --hard $AUTORECONFIGURE_UPSTREAM_BRANCH && cd slave && ./deploy.bash"',
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

# clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
cron {'docker_cleanup_containers':
  command => 'bash -c "docker rm `docker ps -aq`"',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/6',
  minute  => absent,
  weekday => absent,
}
cron {'docker_cleanup_images':
  command => 'bash -c "docker rmi `docker images --filter dangling=true --quiet`"',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/6',
  minute  => absent,
  weekday => absent,
}
