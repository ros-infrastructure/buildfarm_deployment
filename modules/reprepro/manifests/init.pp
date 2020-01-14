class reprepro {
    # Manually managing reprepro, the puppet formula is too fragile wrt to user management.
    package { 'libarchive13':
      ensure => present,
    }
    package { 'libbz2-1.0':
      ensure => present,
    }
    package { 'libc6':
      ensure => present,
    }
    package { 'libdb5.3':
      ensure => present,
    }
    package { 'libgpg-error0':
      ensure => present,
    }
    package { 'libgpgme11':
      ensure => present,
    }
    package { 'liblzma5':
      ensure => present,
    }
    package { 'zlib1g':
      ensure => present,
    }

    exec { 'install-prebuilt-reprepro-deb':
      command   => '/usr/bin/dpkg -i /tmp/reprepro_5.3.0-1_amd64.deb',
      unless    => '/usr/bin/dpkg-query -l reprepro | tail -1 | grep -qs 5.3.0-1',
      logoutput => on_failure,
      require   => [ File['/tmp/reprepro_5.3.0-1_amd64.deb'], Package['libarchive13'], Package['libbz2-1.0'],
                    Package['libc6'], Package['libdb5.3'], Package['libgpg-error0'], Package['libgpgme11'],
                    Package['liblzma5'], Package['zlib1g'] ]
    }

    file { '/tmp/reprepro_5.3.0-1_amd64.deb':
      source => 'puppet:///modules/reprepro/reprepro_5.3.0-1_amd64.deb',
    }
}
