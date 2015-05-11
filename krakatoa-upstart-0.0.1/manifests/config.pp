class upstart::config {
  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  $dbus_config_source = $upstart::user_jobs ? {
    true    => 'puppet:///modules/upstart/dbus/Upstart.conf.user_jobs',
    false   => 'puppet:///modules/upstart/dbus/Upstart.conf.no_user_jobs',
    default => fail('Invalid value for $upstart::user_jobs'),
  }

  file { $upstart::dbus_config:
    source => $dbus_config_source,
  }

  $user_jobs_ensure = $upstart::user_jobs ? {
    true    => 'present',
    false   => 'absent',
    default => fail('Invalid value for $upstart::user_jos'),
  }

  file { "${upstart::init_dir}/user_jobs.conf":
    ensure => $user_jobs_ensure,
    source => 'puppet:///modules/upstart/user_jobs.conf',
  }
}
