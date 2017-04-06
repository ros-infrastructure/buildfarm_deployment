class profile::osrf::repo {
  package {'git':
    ensure => 'installed',
  }

  package {'openssh-server':
    ensure => 'installed',
  }

  package {'python':
    ensure => 'installed',
  }

  package {'python-yaml':
    ensure => 'installed',
  }

  package {'python-debian':
    ensure => 'installed',
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

  ### install latest docker
  include docker

  file { '/home/jenkins-agent/.ssh':
    ensure => 'directory',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    mode   => '0700',
    require => User['jenkins-agent'],
  }

  file { '/var/repos/docs':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => [
      User['jenkins-agent'],
      File['/var/repos'],
    ]
  }

  file { '/var/repos/rosdistro_cache':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => [
      User['jenkins-agent'],
      File['/var/repos'],
    ]
  }

  file { '/var/repos/status_page':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => [
      User['jenkins-agent'],
      File['/var/repos'],
    ]
  }

  $repo_dirs = ['/var/repos',
  '/var/repos/ubuntu',]

  file { $repo_dirs :
    ensure => 'directory',
    mode   => '0644',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => User['jenkins-agent'],
  }

  $config_dirs = ['/home/jenkins-agent/.buildfarm',
  ]

  file { $config_dirs :
    ensure => 'directory',
    mode   => '0644',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => User['jenkins-agent'],
  }

  file { '/home/jenkins-agent/.buildfarm/reprepro-updater.ini':
    mode => '0600',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    content => hiera('jenkins-agent::reprepro_updater_config'),
    require => File['/home/jenkins-agent/.buildfarm'],
  }

  # Set up apache
  class { 'apache':
    default_vhost => false,
  }

  # Make your repo publicly accessible
  apache::vhost { 'repos':
    port       => '80',
    docroot    => '/var/repos',
    priority   => '10',
    #  servername => 'localhost',
    #  require    => Reprepro::Distribution['precise'],
  }


  # Manually managing reprepro, the puppet formula is too fragile wrt to user management.
  package {'reprepro':
    ensure => 'installed',
  }

  #needed by reprepro-updater
  package {'python-configparser':
    ensure => 'installed',
  }
  # GPG key management

  file { '/home/jenkins-agent/.ssh/gpg_private_key.sec':
    mode => '0600',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    content => hiera('jenkins-agent::gpg_private_key'),
    require => File['/home/jenkins-agent/.ssh'],
  }

  file { '/home/jenkins-agent/.ssh/gpg_public_key.pub':
    mode => '0644',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    content => hiera('jenkins-agent::gpg_public_key'),
    require => File['/home/jenkins-agent/.ssh'],
  }

  file { '/var/repos/repos.key':
    mode => '0644',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    content => hiera('jenkins-agent::gpg_public_key'),
    require => File['/var/repos'],
  }

  $gpg_key_id = hiera('jenkins-agent::gpg_key_id')

  exec { 'import_public_key':
    path        => '/bin:/usr/bin',
    command     => 'gpg --import /home/jenkins-agent/.ssh/gpg_public_key.pub',
    user        => 'jenkins-agent',
    group       => 'jenkins-agent',
    unless      => "gpg --list-keys | grep ${gpg_key_id}",
    logoutput   => on_failure,
    require    => File['/home/jenkins-agent/.ssh/gpg_public_key.pub']
  }

  exec { 'import_private_key':
    path        => '/bin:/usr/bin:',
    command     => 'gpg --import /home/jenkins-agent/.ssh/gpg_private_key.sec',
    user        => 'jenkins-agent',
    group       => 'jenkins-agent',
    unless      => "gpg -K | grep ${gpg_key_id}",
    logoutput   => on_failure,
    require    => File['/home/jenkins-agent/.ssh/gpg_private_key.sec']
  }

  exec {'init_building_repo':
    path        => '/bin:/usr/bin',
    command     => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_building -c',
    environment => ['PYTHONPATH=/home/jenkins-agent/reprepro-updater/src:$PYTHONPATH'],
    user        => 'jenkins-agent',
    group       => 'jenkins-agent',
    unless      => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_building -q',
    logoutput   => on_failure,
    require     => [
      Vcsrepo['/home/jenkins-agent/reprepro-updater'],
      File['/home/jenkins-agent/.buildfarm/reprepro-updater.ini'],
    ]
  }

  exec {'init_testing_repo':
    path        => '/bin:/usr/bin',
    command     => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_testing -c',
    environment => ['PYTHONPATH=/home/jenkins-agent/reprepro-updater/src:$PYTHONPATH'],
    user        => 'jenkins-agent',
    group       => 'jenkins-agent',
    unless      => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_testing -q',
    logoutput   => on_failure,
    require     => [
      Vcsrepo['/home/jenkins-agent/reprepro-updater'],
      File['/home/jenkins-agent/.buildfarm/reprepro-updater.ini'],
    ]
  }

  exec {'init_main_repo':
    path        => '/bin:/usr/bin',
    command     => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_main -c',
    environment => ['PYTHONPATH=/home/jenkins-agent/reprepro-updater/src:$PYTHONPATH'],
    user        => 'jenkins-agent',
    group       => 'jenkins-agent',
    unless      => '/home/jenkins-agent/reprepro-updater/scripts/setup_repo.py ubuntu_testing -q',
    logoutput   => on_failure,
    require     => [
      Vcsrepo['/home/jenkins-agent/reprepro-updater'],
      File['/home/jenkins-agent/.buildfarm/reprepro-updater.ini'],
    ]
  }
  # needed for boostrapping the repo
  vcsrepo { '/home/jenkins-agent/reprepro-updater':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/ros-infrastructure/reprepro-updater.git',
    revision => 'refactor',
    user     => 'jenkins-agent',
    require => User['jenkins-agent'],
  }


  # Create directory for reprepro_config
  file { '/home/jenkins-agent/reprepro_config':
    ensure => 'directory',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    mode   => '0700',
    require => User['jenkins-agent'],
  }

  # Pull reprepro updater
  if hiera('jenkins-agent::reprepro_config', false){
    create_resources(file, hiera('jenkins-agent::reprepro_config'))
  }
}
