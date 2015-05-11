class upstart::install {
  package { $upstart::package:
    ensure => $upstart::package_version,
  }
}
