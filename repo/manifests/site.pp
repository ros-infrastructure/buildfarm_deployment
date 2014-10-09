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
              '/var/repos/ubuntu',]

file { $repo_dirs :
  ensure => 'directory',
  mode   => 644,
  owner  => 'reprepro',
  group  => 'reprepro',
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



class { 'reprepro':
}

# Set up a repository
reprepro::repository { 'building':
  ensure  => present,
  basedir => '/var/repos/ubuntu',
  options => ['basedir .'],
}

# Create a distribution within that repository
reprepro::distribution { 'precise_building':
  basedir       => '/var/repos/ubuntu',
  repository    => 'building',
  origin        => 'Foobar',
  label         => 'Foobar',
  suite         => 'precise',
  architectures => 'amd64 i386',
  components    => 'main contrib non-free',
  description   => 'Package repository for local site maintenance',
  #sign_with     => 'F4D5DAA8',
  not_automatic => 'No',
}

# Set up a repository
reprepro::repository { 'testing':
  ensure  => present,
  basedir => '/var/repos/ubuntu',
  options => ['basedir .'],
}

# Create a distribution within that repository
reprepro::distribution { 'precise_testing':
  basedir       => '/var/repos/ubuntu',
  repository    => 'testing',
  origin        => 'Foobar',
  label         => 'Foobar',
  suite         => 'precise',
  architectures => 'amd64 i386',
  components    => 'main contrib non-free',
  description   => 'Package repository for local site maintenance',
  #sign_with     => 'F4D5DAA8',
  not_automatic => 'No',
}

# Set up the main repository
reprepro::repository { 'main':
  ensure  => present,
  basedir => '/var/repos/ubuntu',
  options => ['basedir .'],
}

# Create an example distribution within that repository
reprepro::distribution { 'precise_main':
  basedir       => '/var/repos/ubuntu',
  repository    => 'main',
  origin        => 'Foobar',
  label         => 'Foobar',
  suite         => 'precise',
  architectures => 'amd64 i386',
  components    => 'main contrib non-free',
  description   => 'Package repository for local site maintenance',
  #sign_with     => 'F4D5DAA8',
  not_automatic => 'No',
}
