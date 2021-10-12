# Jenkins Agent Profile
#
# Profile class for a node configured to act as a swarm agent for Jenkins.
# This profile should only ever be declared with an include into a role or site manifest.
# Parameter overloading should be done using hiera automatic parameter lookup.
#
# @example
#    include profile::jenkins::master
#
# @pararm agent_username The unix user the agent will configure and run as.
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
    slave_user => $agent_username,
    slave_home => "/home/${agent_username}",
    manage_slave_user => false,
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

  class { 'python' :
    version => 'python3',
    pip     => 'present',
  }

  # required by cleanup_docker_images.py
  package { 'python3-dateutil':
    ensure => 'installed',
  }

  ## required by jobs to generate Dockerfiles
  package { 'python3-empy':
    ensure => 'installed',
  }

  # required by subprocess reaper and docker cleanup scripts
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

  include docker

  file { '/etc/docker/seccomp-profiles':
    ensure  => directory,
    require => Class[docker],
  }

  file { '/etc/docker/seccomp-profiles/docker-default-with-personality.json':
    source  => 'puppet:///modules/agent_files/docker-default-seccomp-with-personality.json',
    require => [Class[docker], File['/etc/docker/seccomp-profiles']],
  }

  file { '/etc/docker/daemon.json':
    source  => 'puppet:///modules/agent_files/docker-daemon.json',
    require => Class[docker],
  }

  package { 'iptables-persistent':
    ensure => 'installed',
  }

  # docker versions < 19.03.3 don't provide the DOCKER-USER chain
  exec { 'setup_docker_iptables_chain':
    user    => 'root',
    unless  => '/sbin/iptables -nL DOCKER-USER',
    command => '/sbin/iptables -A DOCKER-USER -j RETURN && /sbin/iptables -I FORWARD -j DOCKER-USER && /sbin/iptables -N DOCKER-USER',
    before  => Exec['setup_iptables_ec2_block_for_docker'],
    require => Class[docker],
  }

  exec { 'setup_iptables_ec2_block_for_docker':
    user    => 'root',
    unless  => '/sbin/iptables -nL DOCKER-USER  | grep REJECT.*169.254.169.254',
    command => '/sbin/iptables --insert DOCKER-USER --destination 169.254.169.254 --jump REJECT',
    before  => Exec['save_iptables_rule'],
    require => Exec['setup_docker_iptables_chain'],
  }

  exec { 'save_iptables_rule':
    user    => 'root',
    command => '/sbin/iptables-save > /etc/iptables/rules.v4',
    require => [Exec['setup_iptables_ec2_block_for_docker'], Package['iptables-persistent']],
  }

  # required by cleanup_docker script
  python::pip { 'docker':
    ensure  => '2.5.0',
    pkgname => 'docker',
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

  exec { 'systemctl-daemon-reload':
    command => '/bin/systemctl daemon-reload',
    require => File['/etc/init.d/jenkins-slave'],
    before  => Service['jenkins-slave'],
  }
}
