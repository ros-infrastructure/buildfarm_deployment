class profile::jenkins::agent {

  ### Jenkins Slave
  ## Don't install java to avoid conflict with the master puppet formula
  ## https://github.com/jenkinsci/puppet-jenkins/issues/224
  class { 'jenkins::slave':
    #labels => 'on_master',
    slave_mode => 'exclusive',
    slave_name => 'slave_on_master',
    slave_user => 'jenkins-agent',
    manage_slave_user => false,
    executors => '1',
    install_java => false,
    require => User['jenkins-agent'],
  }

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

  user{'jenkins-agent':
    ensure => present,
    managehome => true,
    groups => ['docker'],
    require => Package['docker.io']
  }

}
