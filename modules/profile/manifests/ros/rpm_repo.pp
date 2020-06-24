define profile::ros::rpm_repo(
  $distro_name,
  $distro_ver,
  $distro_arches,
) {
  pulp::rpm_repo { "ros-${distro_name}-${distro_ver}-SRPMS":
    repo_endpoints => [
      "ros-building-${distro_name}-${distro_ver}-SRPMS",
      "ros-testing-${distro_name}-${distro_ver}-SRPMS",
      "ros-main-${distro_name}-${distro_ver}-SRPMS",
    ],
    require => Class['pulp'],
  }

  ['building', 'testing', 'main'].each |String $repo_name| {
    file { "/var/repos/${distro_name}/${repo_name}/${distro_ver}":
      ensure => 'directory',
      owner  => $agent_username,
      group  => $agent_username,
      mode   => '0755',
      require => File["/var/repos/${distro_name}/${repo_name}"],
    }
    -> file { "/var/repos/${distro_name}/${repo_name}/${distro_ver}/SRPMS":
      ensure => 'directory',
      owner  => $agent_username,
      group  => $agent_username,
      mode   => '0755',
    }
  }

  $distro_arches.each |String $distro_arch| {
    pulp::rpm_repo { "ros-${distro_name}-${distro_ver}-${distro_arch}":
      repo_endpoints => [
        "ros-building-${distro_name}-${distro_ver}-${distro_arch}",
        "ros-testing-${distro_name}-${distro_ver}-${distro_arch}",
        "ros-main-${distro_name}-${distro_ver}-${distro_arch}",
      ],
      require => Class['pulp'],
    }

    pulp::rpm_repo { "ros-${distro_name}-${distro_ver}-${distro_arch}-debug":
      repo_endpoints => [
        "ros-building-${distro_name}-${distro_ver}-${distro_arch}-debug",
        "ros-testing-${distro_name}-${distro_ver}-${distro_arch}-debug",
        "ros-main-${distro_name}-${distro_ver}-${distro_arch}-debug",
      ],
      require => Class['pulp'],
    }

    ['building', 'testing', 'main'].each |String $repo_name| {
      file { "/var/repos/${distro_name}/${repo_name}/${distro_ver}/${distro_arch}":
        ensure => 'directory',
        owner  => $agent_username,
        group  => $agent_username,
        mode   => '0755',
        require => File["/var/repos/${distro_name}/${repo_name}/${distro_ver}"],
      }
    }
  }
}
