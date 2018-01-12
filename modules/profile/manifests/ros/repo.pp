class profile::ros::repo {
  require profile::jenkins::agent
  # This is not a class parameter so it cannot be overloaded separately from the jenkins::agent value.
  $agent_username = $profile::jenkins::agent::agent_username

  include reprepro

  package {'openssh-server':
    ensure => 'installed',
  }

  package {'python-yaml':
    ensure => 'installed',
  }

  package {'python-debian':
    ensure => 'installed',
  }

  file { '/var/repos/docs':
    ensure => 'directory',
    mode   => '0755',
    owner  => $agent_username,
    group  => $agent_username,
    require => [
      User[$agent_username],
      File['/var/repos'],
    ]
  }

  file { '/var/repos/rosdistro_cache':
    ensure => 'directory',
    mode   => '0755',
    owner  => $agent_username,
    group  => $agent_username,
    require => [
      User[$agent_username],
      File['/var/repos'],
    ]
  }

  file { '/var/repos/status_page':
    ensure => 'directory',
    mode   => '0755',
    owner  => $agent_username,
    group  => $agent_username,
    require => [
      User[$agent_username],
      File['/var/repos'],
    ]
  }

  $repo_dirs = ['/var/repos',
  '/var/repos/ubuntu',]

  file { $repo_dirs :
    ensure => 'directory',
    mode   => '0644',
    owner  => $agent_username,
    group  => $agent_username,
    require => User[$agent_username],
  }

  file { "/home/${agent_username}/upload_triggers":
    ensure => directory,
  }

  if hiera('upload_keys', false) {
    hiera('upload_keys').each |$name, $content| {
      file { "/home/${agent_username}/upload_triggers/${name}":
        content => $content,
        mode    => '0400',
        owner   => $agent_username,
        group   => $agent_username,
        require => File["/home/${agent_username}/upload_triggers"],
      }

    }
  }


  file { "/home/${agent_username}/upload_triggers/upload_repo.bash":
    source => 'puppet:///modules/profile/ros/repo/upload_repo.bash',
    mode   => '0744',
    owner  =>  $agent_username,
    group  =>  $agent_username,
    require => File["/home/${agent_username}/upload_triggers"],
  }

  $config_dirs = ["/home/${agent_username}/.buildfarm",
  ]

  file { $config_dirs :
    ensure => 'directory',
    mode   => '0644',
    owner  => $agent_username,
    group  => $agent_username,
    require => User[$agent_username],
  }

  file { "/home/${agent_username}/.buildfarm/reprepro-updater.ini":
    mode => '0600',
    owner  => $agent_username,
    group  => $agent_username,
    content => hiera('jenkins-agent::reprepro_updater_config'),
    require => File["/home/${agent_username}/.buildfarm"],
  }

  # Set up apache
  class { 'apache':
    default_vhost => false,
  }

  # Make your repo publicly accessible
  apache::vhost { 'repos':
    port       => '80',
    docroot    => '/var/repos',
    priority   => '10',
    #  servername => 'localhost',
    #  require    => Reprepro::Distribution['precise'],
    }

    #needed by reprepro-updater
    package {'python-configparser':
      ensure => 'installed',
    }

    ## GPG key management
    file { "/home/${agent_username}/.gnupg/gpg.conf":
      owner  => $agent_username,
      group  => $agent_username,
      source => 'puppet:///modules/profile/ros/repo/gpg.conf',
      require => File["/home/${agent_username}/.ssh"],
    }

    file { "/home/${agent_username}/.ssh/gpg_private_key.sec":
      mode => '0600',
      owner  => $agent_username,
      group  => $agent_username,
      content => hiera('jenkins-agent::gpg_private_key'),
      require => File["/home/${agent_username}/.ssh"],
    }

    file { "/home/${agent_username}/.ssh/gpg_public_key.pub":
      mode => '0644',
      owner  => $agent_username,
      group  => $agent_username,
      content => hiera('jenkins-agent::gpg_public_key'),
      require => File["/home/${agent_username}/.ssh"],
    }

    file { '/var/repos/repos.key':
      mode => '0644',
      owner  => $agent_username,
      group  => $agent_username,
      content => hiera('jenkins-agent::gpg_public_key'),
      require => File['/var/repos'],
    }

    $gpg_key_id = hiera('jenkins-agent::gpg_key_id')

    exec { 'import_public_key':
      path        => '/bin:/usr/bin',
      command     => "gpg --import /home/${agent_username}/.ssh/gpg_public_key.pub",
      user  => $agent_username,
      group  => $agent_username,
      unless      => "gpg --list-keys | grep ${gpg_key_id}",
      logoutput   => on_failure,
      require    => File["/home/${agent_username}/.ssh/gpg_public_key.pub"]
    }

    exec { 'import_private_key':
      path        => '/bin:/usr/bin:',
      command     => "gpg --import /home/${agent_username}/.ssh/gpg_private_key.sec",
      user  => $agent_username,
      group  => $agent_username,
      unless      => "gpg -K | grep ${gpg_key_id}",
      logoutput   => on_failure,
      require    => File["/home/${agent_username}/.ssh/gpg_private_key.sec"]
    }

    ['building', 'testing', 'main'].each |String $reponame| {
      exec {"init_${reponame}_repo":
        path        => '/bin:/usr/bin',
        command     => "python /home/${agent_username}/reprepro-updater/scripts/setup_repo.py ubuntu_${reponame} -c",
        environment => ["PYTHONPATH=/home/${agent_username}/reprepro-updater/src"],
        user  => $agent_username,
        group  => $agent_username,
        unless      => "python /home/${agent_username}/reprepro-updater/scripts/setup_repo.py ubuntu_${reponame} -q",
        logoutput   => on_failure,
        require     => [
          Vcsrepo["/home/${agent_username}/reprepro-updater"],
          File["/home/${agent_username}/.buildfarm/reprepro-updater.ini"],
          Package['python-yaml'],
        ]
      }
    }

    # needed for boostrapping the repo
    vcsrepo { "/home/${agent_username}/reprepro-updater":
      ensure   => latest,
      provider => git,
      source   => 'https://github.com/ros-infrastructure/reprepro-updater.git',
      revision => 'refactor',
      user     => $agent_username,
      require => User[$agent_username],
    }

    # Create directory for reprepro_config
    file { "/home/${agent_username}/reprepro_config":
      ensure => 'directory',
      owner  => $agent_username,
      group  => $agent_username,
      mode   => '0700',
      require => User[$agent_username],
    }

    # Pull reprepro updater
    if hiera('jenkins-agent::reprepro_config', false){
      create_resources(file, hiera('jenkins-agent::reprepro_config'))
    }
}
