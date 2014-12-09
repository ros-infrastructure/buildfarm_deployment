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
  require => [User['jenkins-slave'],
              Package['docker'],
             ],
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

class {'docker':
  manage_kernel => false,
}

# use wrapdocker from dind
file { '/home/jenkins-slave/wrapdocker':
    mode => '0774',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    source => 'puppet:///modules/slave_files/home/jenkins-slave/wrapdocker',
    require => User['jenkins-slave'],
}


if hiera('run_squid', false) {
  docker::image {'jpetazzo/squid-in-a-can':
    require => Package['docker'],
  }

  file { '/var/cache/squid-in-a-can' :
    ensure => 'directory',
    mode   => 644,
    owner  => 'proxy',
    group  => 'proxy',
  }

  docker::run {'squid-in-a-can':
    image   => 'jpetazzo/squid-in-a-can',
    command => '/tmp/deploy_squid.py',
    env     => ['DISK_CACHE_SIZE=5000', 'MAX_CACHE_OBJECT=1000'],
    volumes => ['/var/cache/squid-in-a-can:/var/cache/squid3'],
    net     => 'host',
    require => [Docker::Image['jpetazzo/squid-in-a-can'],
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
