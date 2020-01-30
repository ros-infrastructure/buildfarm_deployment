class pulp {
  file { '/tmp/pulp':
    ensure => 'directory',
    mode   => '0700',
  }

  file { '/tmp/pulp/Dockerfile':
    ensure => 'file',
    mode   => '0600',
    source => 'puppet:///modules/pulp/Dockerfile',
    require => File['/tmp/pulp'],
  }

  file { '/tmp/pulp/entry_point.sh':
    ensure => 'file',
    mode   => '0755',
    source => 'puppet:///modules/pulp/entry_point.sh',
    require => File['/tmp/pulp'],
  }

  file { '/tmp/pulp_rpm_repo':
    ensure => 'directory',
    mode   => '0700',
  }

  file { '/tmp/pulp_rpm_repo/initialize.py':
    ensure => 'file',
    mode   => '0600',
    source => 'puppet:///modules/pulp/rpm_repo_init.py',
    require => File['/tmp/pulp_rpm_repo'],
  }
}
