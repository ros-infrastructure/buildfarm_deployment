class profile::jenkins::agent (
  String $agent_username = 'jenkins-agent',
) {

  user { $agent_username :
    ensure => present,
    managehome => true,
    groups => ['docker'],
    # Docker is required so the docker group is created.
    # We could technically depend on the docker group but this ensures the docker group id is the one
    # preferred by the docker installation.
    require => Class['docker'],
  }

  # Setup SSH known hosts
  file { "/home/${agent_username}/.ssh/" :
    ensure => 'directory',
    mode   => '0644',
    owner  => $agent_username,
    group  => $agent_username,
    require => User[$agent_username],
  }

  file { "/home/${agent_username}/.ssh/known_hosts":
    ensure => 'present',
    mode => '0644',
    owner => $agent_username,
    group => $agent_username,
    content => template('agent_files/known_hosts.erb'),
    require => File["/home/${agent_username}/.ssh/"],
  }

  class { 'jenkins::slave':
    labels => 'buildslave',
    slave_mode => 'exclusive',
    slave_user => $agent_username,
    manage_slave_user => false,
    executors => hiera('jenkins::agent::num_executors', 1),
    require => User[$agent_username],
  }

  # Make sure this directory exists so it can be mounted.
  file { "/home/${agent_username}/.ccache" :
    ensure => 'directory',
    mode   => '0644',
    owner  => $agent_username,
    group  => $agent_username,
    require => User[$agent_username],
  }

  # Must be declared for pip installation module to succeed.
  package {'curl':
    ensure => present,
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

  package { 'git':
    ensure => 'installed',
  }

  package { 'subversion':
    ensure => 'installed',
  }

  package { 'mercurial':
    ensure => 'installed',
  }

  package { 'bzr':
    ensure => 'installed',
  }

  # required for armhf builds
  package { 'qemu-user-static':
    ensure => 'installed',
  }

  package { 'python3-pip':
    ensure => 'installed',
  }

  include docker

  # required by cleanup_docker script
  pip::install { 'docker-py':
    #package => 'jenkinsapi', # defaults to $title
    #version => '1.6', # if undef installs latest version
    python_version => '3', # defaults to 2.7
    #ensure => present, # defaults to present
    require => Package['python3-pip'],
  }

  # script to clean up docker images from oldest
  file { "/home/${agent_username}/cleanup_docker_images.py":
    mode => '0774',
    owner => $agent_username,
    group => $agent_username,
    source => 'puppet:///modules/agent_files/home/jenkins-agent/cleanup_docker_images.py',
    require => User[$agent_username],
  }

  # clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
  cron {'docker_cleanup_images':
    command => "bash -c \"python3 -u /home/${agent_username}/cleanup_docker_images.py --minimum-free-percent 10 --minimum-free-space 50\"",
    user    => $agent_username,
    month   => absent,
    monthday => absent,
    hour    => '*',
    minute  => '*/15',
    weekday => absent,
    require => User[$agent_username],
  }
}
