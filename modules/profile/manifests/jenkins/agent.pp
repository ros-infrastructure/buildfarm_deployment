class profile::jenkins::agent {

  # Must be declared for pip installation module to succeed.
  package {'curl':
    ensure => present,
  }

  # Setup SSH known hosts
  file { '/home/jenkins-agent/.ssh/' :
    ensure => 'directory',
    mode   => '644',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => User['jenkins-agent'],
  }

  file { '/home/jenkins-agent/.ssh/known_hosts':
    ensure => 'present',
    mode => '0644',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    content => template('agent_files/known_hosts.erb'),
    require => File['/home/jenkins-agent/.ssh/'],
  }

  class { 'jenkins::slave':
    labels => 'buildslave',
    slave_mode => 'exclusive',
    slave_user => 'jenkins-agent',
    manage_slave_user => false,
    executors => hiera('jenkins::agent::num_executors', 1),
    require => User['jenkins-agent'],
  }

  user{'jenkins-agent':
    ensure => present,
    managehome => true,
    groups => ['docker'],
    require => Class['docker']
  }

  # Make sure this directory exists so it can be mounted.
  file { '/home/jenkins-agent/.ccache' :
    ensure => 'directory',
    mode   => '644',
    owner  => 'jenkins-agent',
    group  => 'jenkins-agent',
    require => User['jenkins-agent'],
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
  file { '/home/jenkins-agent/cleanup_docker_images.py':
    mode => '0774',
    owner => 'jenkins-agent',
    group => 'jenkins-agent',
    source => 'puppet:///modules/agent_files/home/jenkins-agent/cleanup_docker_images.py',
    require => User['jenkins-agent'],
  }

  # clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
  cron {'docker_cleanup_images':
    command => 'bash -c "python3 -u /home/jenkins-agent/cleanup_docker_images.py --minimum-free-percent 10 --minimum-free-space 50"',
    user    => 'jenkins-agent',
    month   => absent,
    monthday => absent,
    hour    => '*',
    minute  => '*/15',
    weekday => absent,
    require => User['jenkins-agent'],
  }
}
