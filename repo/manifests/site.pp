import 'slave.pp'

file { '/home/jenkins-slave/.ssh':
    ensure => 'directory',
    owner  => 'jenkins-slave',
    group  => 'jenkins-slave',
    mode   => '700',
    require => User['jenkins-slave'],
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

vcsrepo { "/tmp/reprepro-updater":
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

# GPG key management

file { '/home/jenkins-slave/.ssh/gpg_private_key.sec':
    mode => '0600',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
    content => template('repo_files/gpg_private_key.sec.erb'),
    require => File['/home/jenkins-slave/.ssh'],
}
file { '/home/jenkins-slave/.ssh/gpg_public_key.pub':
    mode => '0600',
    owner => 'jenkins-slave',
    group => 'jenkins-slave',
#    content => template('repo_files/gpg_public_key.pub.erb'),
    content => hiera("jenkins-slave::gpg_public_key"),
    require => File['/home/jenkins-slave/.ssh'],
}

exec { "import_public_key":
    path        => '/bin:/usr/bin',
    #environment => 'HOME=/root',
    command     => "gpg --import /home/jenkins-slave/.ssh/gpg_public_key.pub",
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    #unless      => "apt-key list | grep $keyid",
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_public_key.pub']
}

exec { "import_private_key":
    path        => '/bin:/usr/bin',
    #environment => 'HOME=/root',
    command     => "gpg --import /home/jenkins-slave/.ssh/gpg_private_key.sec",
    user        => 'jenkins-slave',
    group       => 'jenkins-slave',
    #unless      => "apt-key list | grep $keyid",
    logoutput   => on_failure,
    require    => File['/home/jenkins-slave/.ssh/gpg_private_key.sec']
}
