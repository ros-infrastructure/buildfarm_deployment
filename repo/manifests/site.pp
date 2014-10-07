import 'slave.pp'


package {"git":
  ensure => "installed",
}

package {"python":
  ensure => "installed",
}

package {"python-yaml":
  ensure => "installed",
}



$repo_dirs = ['/var/repos',
              '/var/repos/ubuntu',
              '/var/repos/ubuntu/building',
              '/var/repos/ubuntu/testing',
              '/var/repos/ubuntu/main',]

file { $repo_dirs :
  ensure => 'directory',
  mode   => 644,
  owner  => 'jenkins-slave',
  group  => 'jenkins-slave',
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


# class { 'reprepro':
# }
#
# # Set up a repository
# reprepro::repository { 'building':
#   ensure  => present,
#   basedir => '/var/repos/ubuntu/building',
#   options => ['basedir .'],
#   owner  => 'jenkins-slave',
#   group  => 'jenkins-slave',
# }

# Create a distribution within that repository
# reprepro::distribution { 'precise':
#   basedir       => '/var/repos/ubuntu/building',
#   repository    => 'building',
#   origin        => 'Foobar',
#   label         => 'Foobar',
#   suite         => 'precise',
#   architectures => 'amd64 i386',
#   components    => 'main contrib non-free',
#   description   => 'Package repository for local site maintenance',
#   #sign_with     => 'F4D5DAA8',
#   not_automatic => 'No',
# }
