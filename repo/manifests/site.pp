class { 'jenkins::slave':
  labels => "building_repository",
  slave_mode => "exclusive",
  slave_name => 'building_repository',
  manage_slave_user => true,
  executors => "1",
}

exec {"jenkins-slave docker membership":
  path    => '/usr/sbin:/usr/bin:/sbin:/bin',
  unless => "grep -q 'docker\\S*jenkins-slave' /etc/group",
  command => "usermod -aG docker jenkins-slave",
  require => [User['jenkins-slave'],
              Package['lxc-docker'],
             ],
}



# setup ntp with defaults
include '::ntp'

### install latest docker

class {'docker':
}

# use wrapdocker from dind
file { '/home/jenkins-slave/wrapdocker':
    mode => '0774',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    source => 'puppet:///modules/repo_files/home/jenkins-slave/wrapdocker',
    require => User['jenkins-slave'],
}

# clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
cron {'docker_cleanup_containers':
  command => 'bash -c "docker ps -aq | xargs -L1 docker rm "',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/6',
  minute  => absent,
  weekday => absent,
}
cron {'docker_cleanup_images':
  command => 'bash -c "docker images --filter dangling=true --quiet | xargs -L1 docker rmi "',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/6',
  minute  => absent,
  weekday => absent,
}

# Find the other instances
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

# required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}

# required by subprocess reaper script
package { 'python3-psutil':
  ensure => 'installed',
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

$gpg_key_id = hiera('jenkins-slave::gpg_key_id')

exec { "import_public_key":
    path        => '/bin:/usr/bin',
    command     => 'gpg --import /home/jenkins-slave/.ssh/gpg_public_key.pub',
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    unless      => "gpg --list-keys | grep ${gpg_key_id}",
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_public_key.pub']
}

exec { "import_private_key":
    path        => '/bin:/usr/bin:',
    command     => 'gpg --import /home/jenkins-slave/.ssh/gpg_private_key.sec',
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    unless      => "gpg -K | grep ${gpg_key_id}",
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_private_key.sec']
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


exec {"init_building_repo":
  path        => '/bin:/usr/bin',
  command     => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_building -c',
  environment => ['PYTHONPATH=/home/jenkins-slave/reprepro-updater/src:$PYTHONPATH'],
  user        => 'jenkins-slave',
  group       => 'jenkins-slave',
  unless      => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_building -q',
  logoutput   => on_failure,
  require     => [
                  Vcsrepo ["/home/jenkins-slave/reprepro-updater"],
                  File['/home/jenkins-slave/.buildfarm/reprepro-updater.ini'],
                 ]
}

exec {"init_testing_repo":
  path        => '/bin:/usr/bin',
  command     => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_testing -c',
  environment => ['PYTHONPATH=/home/jenkins-slave/reprepro-updater/src:$PYTHONPATH'],
  user        => 'jenkins-slave',
  group       => 'jenkins-slave',
  unless      => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_testing -q',
  logoutput   => on_failure,
  require     => [
                  Vcsrepo ["/home/jenkins-slave/reprepro-updater"],
                  File['/home/jenkins-slave/.buildfarm/reprepro-updater.ini'],
                 ]
}

exec {"init_main_repo":
  path        => '/bin:/usr/bin',
  command     => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_main -c',
  environment => ['PYTHONPATH=/home/jenkins-slave/reprepro-updater/src:$PYTHONPATH'],
  user        => 'jenkins-slave',
  group       => 'jenkins-slave',
  unless      => '/home/jenkins-slave/reprepro-updater/scripts/setup_repo.py ubuntu_testing -q',
  logoutput   => on_failure,
  require     => [
                  Vcsrepo ["/home/jenkins-slave/reprepro-updater"],
                  File['/home/jenkins-slave/.buildfarm/reprepro-updater.ini'],
                 ]
}
