class { 'jenkins::slave':
  labels => "building_repository",
  slave_mode => "exclusive",
  slave_name => 'building_repository',
  manage_slave_user => false,
  executors => "1",
  require => User['jenkins-slave'],
}

user{'jenkins-slave':
  ensure => present,
  managehome => true,
  groups => ['docker'],
  require => Package['lxc-docker']
}


# setup ntp with defaults
include '::ntp'

# bring in classes listed in hiera
if hiera('classes', false) {
  hiera_include('classes')
}

### install latest docker

class {'docker':
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

file { '/var/repos/docs':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-slave',
    group  => 'jenkins-slave',
    require => [
      User['jenkins-slave'],
      File['/var/repos'],
    ]
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


# Setup generic ssh_keys
if hiera('ssh_keys', false){
  $defaults = {
    'ensure' => 'present',
  }
  create_resources(ssh_authorized_key, hiera('ssh_keys'), $defaults)
}
else{
  notice("No ssh_keys defined. You need at least one for jenkins-slave.")
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

# required by cleanup_docker_images.py
package { 'python3-dateutil':
  ensure => 'installed',
}
# required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}

# required by subprocess reaper script
package { 'python3-psutil':
  ensure => 'installed',
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

# script to clean up docker images from oldest
file { '/home/jenkins-slave/cleanup_docker_images.py':
  mode => '0774',
  owner => 'jenkins-slave',
  group => 'jenkins-slave',
  source => 'puppet:///modules/repo_files/home/jenkins-slave/cleanup_docker_images.py',
  require => User['jenkins-slave'],
}

# clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
cron {'docker_cleanup_images':
  command => 'bash -c "python3 -u /home/jenkins-slave/cleanup_docker_images.py"',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/2',
  minute  => 15,
  weekday => absent,
  require => User['jenkins-slave'],
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

# remove old cron jobs from previously configured re #46
# This can be removed once there are verified to be no machines running this cron job.
cron {'docker_cleanup_containers':
  ensure => 'absent',
  user    => 'jenkins-slave',
}

# needed for boostrapping the repo
vcsrepo { "/home/jenkins-slave/reprepro-updater":
  ensure   => latest,
  provider => git,
  source   => 'https://github.com/ros-infrastructure/reprepro-updater.git',
  revision => 'refactor',
  user     => 'jenkins-slave',
  require => User['jenkins-slave'],
}


# Create directory for reprepro_config
file { '/home/jenkins-slave/reprepro_config':
  ensure => 'directory',
  owner  => 'jenkins-slave',
  group  => 'jenkins-slave',
  mode   => '700',
  require => User['jenkins-slave'],
}

# Pull reprepro updater
if hiera('jenkins-slave::reprepro_config', false){
  create_resources(file, hiera('jenkins-slave::reprepro_config'))
}
