class upstart (
  $package         = $upstart::params::package,
  $package_version = 'installed',
  $user_jobs       = false,
  $init_dir        = $upstart::params::init_dir,
  $dbus_config     = $upstart::params::dbus_config
) inherits upstart::params {

  validate_bool($user_jobs)

  anchor { 'upstart::begin':
    before => Class['upstart::install'],
  }

  class { 'upstart::install': }

  class { 'upstart::config':
    require => Class['upstart::install'],
  }

  anchor { 'upstart::end':
    require => Class['upstart::config'],
  }
}
