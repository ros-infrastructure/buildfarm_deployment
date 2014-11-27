class { 'jenkins::slave':
  labels => "building_repository",
  slave_mode => "exclusive",
  slave_name => 'building_repository',
  manage_slave_user => true,
  executors => "1",
}


# setup ntp with defaults
include '::ntp'

# Find the other instances
host {'master':
  ip => hiera('master::ip'),
}

file { '/home/jenkins-slave/.ssh':
    ensure => 'directory',
    owner  => 'jenkins-slave',
    group  => 'jenkins-slave',
    mode   => '700',
    require => User['jenkins-slave'],
}

file { '/var/repos/rosdistro_cache':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-slave',
    group  => 'jenkins-slave',
    require => [
      User['jenkins-slave'],
      File['/var/repos'],
    ]
}

file { '/var/repos/status_page':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-slave',
    group  => 'jenkins-slave',
    require => [
      User['jenkins-slave'],
      File['/var/repos'],
    ]
}

# TODO make this parameterized. This is a hack to get up and running on
# the local development machines only!!!!!!
# add ssh key
file { '/home/jenkins-slave/.ssh/authorized_keys':
    mode => '0600',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => hiera("jenkins-slave::authorized_keys"),
    require => File['/home/jenkins-slave/.ssh'],
}

package {"git":
  ensure => "installed",
}

package {"openssh-server":
  ensure => "installed",
}

package {"python":
  ensure => "installed",
}

package {"python-yaml":
  ensure => "installed",
}

package {"python-debian":
  ensure => "installed",
}

vcsrepo { "/home/jenkins-slave/reprepro-updater":
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/ros-infrastructure/reprepro-updater.git',
  revision => 'refactor',
  user     => 'jenkins-slave',
  require => User['jenkins-slave'],
}

$repo_dirs = ['/var/repos',
              '/var/repos/ubuntu',]

file { $repo_dirs :
  ensure => 'directory',
  mode   => 644,
  owner  => 'jenkins-slave',
  group  => 'jenkins-slave',
  require => User['jenkins-slave'],
}

$config_dirs = ['/home/jenkins-slave/.buildfarm',
              ]

file { $config_dirs :
  ensure => 'directory',
  mode   => 644,
  owner  => 'jenkins-slave',
  group  => 'jenkins-slave',
  require => User['jenkins-slave'],
}

file { '/home/jenkins-slave/.buildfarm/reprepro-updater.ini':
    mode => '0600',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => hiera('jenkins-slave::reprepro_updater_config'),
    require => File['/home/jenkins-slave/.buildfarm'],
}

# Set up apache
class { 'apache': }

# Make your repo publicly accessible
apache::vhost { 'repos':
  port       => '80',
  docroot    => '/var/repos',
  priority   => '10',
#  servername => 'localhost',
#  require    => Reprepro::Distribution['precise'],
}

# Manually managing reprepro, the puppet formula is too fragile wrt to user management.
package {"reprepro":
  ensure => "installed",
}

#needed by reprepro-updater
package {"python-configparser":
  ensure => "installed",
}
# GPG key management

file { '/home/jenkins-slave/.ssh/gpg_private_key.sec':
    mode => '0600',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => hiera("jenkins-slave::gpg_private_key"),
    require => File['/home/jenkins-slave/.ssh'],
}
file { '/home/jenkins-slave/.ssh/gpg_public_key.pub':
    mode => '0644',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => hiera("jenkins-slave::gpg_public_key"),
    require => File['/home/jenkins-slave/.ssh'],
}

file { '/var/repos/repos.key':
    mode => '0644',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => hiera("jenkins-slave::gpg_public_key"),
    require => File['/var/repos'],
}

exec { "import_public_key":
    path        => '/bin:/usr/bin',
    command     => 'gpg --import /home/jenkins-slave/.ssh/gpg_public_key.pub',
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    #unless      => "apt-key list | grep $keyid", TODO IMPLEMENT THIS CHECK
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_public_key.pub']
}

exec { "import_private_key":
    path        => '/bin:/usr/bin',
    command     => 'gpg --import /home/jenkins-slave/.ssh/gpg_private_key.sec',
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    # unless      => "apt-key list | grep $keyid", TODO IMPLEMENT THIS CHECK
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_private_key.sec']
}

if hiera('autoreconfigure') {
  $autoreconf_key = 'AUTORECONFIGURE_UPSTREAM_BRANCH='
  $branch_str = hiera('autoreconfigure::branch')
  $env_str = "$autoreconf_key$branch_str"
  cron {'autoreconfigure':
    environment => [$env_str,
                    'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
'],
    command => 'bash -c "cd /root/buildfarm_deployment && git fetch origin && git reset --hard $AUTORECONFIGURE_UPSTREAM_BRANCH && cd repo && ./deploy.bash"',
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
