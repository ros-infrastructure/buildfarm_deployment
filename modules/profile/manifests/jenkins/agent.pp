class profile::jenkins::agent {

  # Must be declared for pip installation module to succeed.
  package {'curl':
    ensure => present,
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
}
