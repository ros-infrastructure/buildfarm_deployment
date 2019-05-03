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
class profile::jenkins::agent_gpu {

  include apt

  # neeed for xhost
  package { 'x11-xserver-utils' :
    ensure => installed,
  }

  if $facts['ec2_instance_id'] {
    package { 'linux-aws':
      ensure => installed,
      # When running in EC2 the AWS kernel needs to be installed before
      # compiling the nvidia driver.
      # TODO(nuclearsandwich) Does the xorg.conf really depend on the kernel or
      # is it implicit based on drivers?
      before => [ File['/etc/X11/xorg.conf'], Package['nvidia-375'] ]
    }
  }

  package { 'xserver-xorg-dev':
    ensure => installed,
  }

  # needs to update first the kernel and headers before
  # compiling the nvidia driver
  package { 'nvidia-375':
    ensure  => installed,
  }

  file { '/etc/X11/xorg.conf':
    source  => 'puppet:///modules/profile/jenkins/agent_gpu/etc/X11/xorg.conf',
    mode    => '0744',
    require => [
      Package[lightdm],
      Package['nvidia-375'],
      Package['x11-xserver-utils'],
      Package[xserver-xorg-dev],
    ],
  }

  apt::key { 'nvidia_docker_key' :
    source => 'https://nvidia.github.io/nvidia-docker/gpgkey',
    id     => 'C95B321B61E88C1809C4F759DDCAE044F796ECB0',
  }

  file { '/etc/apt/sources.list.d/nvidia-docker.list':
    source  => 'puppet:///modules/profile/jenkins/agent_gpu/nvidia-docker.list',
    require => [ Apt::Key['nvidia_docker_key'] ]
  }

  package { 'nvidia-docker2':
    ensure  => installed,
    require => [ File['/etc/apt/sources.list.d/nvidia-docker.list'], Exec['apt_update'] ]
  }

  package { 'lightdm':
    ensure => installed,
  }

  file { '/etc/lightdm/xhost.sh':
    source  => 'puppet:///modules/profile/jenkins/agent_gpu/etc/lightdm/xhost.sh',
    mode    => '0744',
    require => [ Package[lightdm], Package[x11-xserver-utils] ]
  }

  # This two rules do: check if no lightdm is present and create one
  # Ensure that display-setup-script is set

  file { '/etc/lightdm/lightdm.conf':
    ensure  => 'present',
    source  => 'puppet:///modules/profile/jenkins/agent_gpu/etc/lightdm/lightdm.conf',
    replace => 'no', # this is the important property
    require => [ File['/etc/lightdm/xhost.sh'], File['/etc/X11/xorg.conf'] ]
  }

  file_line { '/etc/lightdm/lightdm.conf':
    ensure  => present,
    require => File['/etc/lightdm/lightdm.conf'],
    line    => 'display-setup-script=/etc/lightdm/xhost.sh',
    notify  => Service[lightdm],
    path    => '/etc/lightdm/lightdm.conf',
  }

  service { 'lightdm':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }
}
