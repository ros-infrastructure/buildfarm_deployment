class reprepro {
    # Manually managing reprepro, the puppet formula is too fragile wrt to user management.
    package { 'debhelper':
      ensure => present,
    }
    package { 'libarchive-dev':
      ensure => present,
    }
    package { 'libbz2-dev':
      ensure => present,
    }
    package { 'libdb-dev':
      ensure => present,
    }
    package { 'libgpgme11-dev':
      ensure => present,
    }
    package { 'liblzma-dev':
      ensure => present,
    }
    package { 'libz-dev':
      ensure => present,
    }

    exec { 'install-prebuilt-reprepro-deb':
      command   => '/usr/bin/dpkg -i /tmp/reprepro_5.1.1-1_amd64.deb',
      unless    => '/usr/bin/dpkg-query -l reprepro | tail -1 | grep -qs 5.1.1-1',
      logoutput => on_failure,
      require   => File['/tmp/reprepro_5.1.1-1_amd64.deb']
    }

    file { '/tmp/reprepro_5.1.1-1_amd64.deb':
      source => 'puppet://modules/reprepro/reprepro_5.1.1-1_amd64.deb',
    }
}
