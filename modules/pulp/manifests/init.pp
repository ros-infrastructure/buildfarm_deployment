class pulp {
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
