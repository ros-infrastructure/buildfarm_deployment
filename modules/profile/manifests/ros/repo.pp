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

  class { 'apache::mod::rewrite':
  }

  # Make your repo publicly accessible
  apache::vhost { 'repos':
    port       => '80',
    docroot    => '/var/repos',
    priority   => '10',
    override   => 'FileInfo',
    #  servername => 'localhost',
    #  require    => Reprepro::Distribution['precise'],
    }

    #needed by reprepro-updater
    package {'python-configparser':
      ensure => 'installed',
    }

    ## GPG key management
    file { "/home/${agent_username}/.gnupg":
      owner  => $agent_username,
      group  => $agent_username,
      ensure => directory,
    }

    file { "/home/${agent_username}/.gnupg/gpg.conf":
      owner   => $agent_username,
      group   => $agent_username,
      source  => 'puppet:///modules/profile/ros/repo/gpg.conf',
      require => File["/home/${agent_username}/.gnupg"],
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

    # GPG vault

    user { 'gpg-vault' :
      ensure => present,
      managehome => true,
    }
    -> exec { 'gpg-init':
      path    => '/bin:/usr/bin:',
      command => 'gpg -K',
      unless  => 'test -d /home/gpg-vault/.gnupg',
      user    => 'gpg-vault',
      group   => 'gpg-vault',
    }
    -> exec { 'gpg-config':
      path    => '/bin:/usr/bin:',
      command => 'echo "extra-socket /var/run/gpg-vault/S.gpg-agent" > /home/gpg-vault/.gnupg/gpg-agent.conf',
      unless  => 'grep -q extra-socket /home/gpg-vault/.gnupg/gpg-agent.conf',
      user    => 'gpg-vault',
      group   => 'gpg-vault',
    }

    file { '/var/run/gpg-vault':
      ensure  => 'directory',
      mode    => 0750,
      owner   => 'gpg-vault',
      group   => 'gpg-vault',
      require => User['gpg-vault'],
    }

    file { '/etc/systemd/system/gpg-vault-agent.service':
      source => 'puppet:///modules/profile/gpg-vault-agent.service',
    }
    ~> exec { 'gpg-vault-agent-service-reload':
      path        => '/bin:/usr/bin:',
      command     => 'systemctl daemon-reload',
      refreshonly => true,
    }
    -> service { 'gpg-vault-agent':
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      require    => File['/var/run/gpg-vault'],
      subscribe  => [
        Exec['gpg-config'],
        File['/etc/systemd/system/gpg-vault-agent.service'],
      ],
    }

    file { '/home/gpg-vault/.gnupg/gpg_public_key.pub':
      mode    => '0644',
      owner   => 'gpg-vault',
      group   => 'gpg-vault',
      content => hiera('jenkins-agent::gpg_public_key'),
      require => Exec['gpg-init'],
    }
    ~> exec { 'import_gpg_public_key':
      path      => '/bin:/usr/bin:',
      command   => 'gpg --import /home/gpg-vault/.gnupg/gpg_public_key.pub',
      user      => 'gpg-vault',
      group     => 'gpg-vault',
      unless    => "gpg --list-keys ${gpg_key_id}",
      logoutput => on_failure,
    }

    file { '/home/gpg-vault/.gnupg/gpg_private_key.sec':
      mode    => '0600',
      owner   => 'gpg-vault',
      group   => 'gpg-vault',
      content => hiera('jenkins-agent::gpg_private_key'),
      require => Exec['gpg-init'],
    }
    ~> exec { 'import_gpg_private_key':
      path      => '/bin:/usr/bin:',
      command   => 'gpg --import /home/gpg-vault/.gnupg/gpg_private_key.sec',
      user      => 'gpg-vault',
      group     => 'gpg-vault',
      unless    => "gpg --list-secret-keys ${gpg_key_id}",
      logoutput => on_failure,
    }

    exec { 'gpg-vault-member-jenkins-agent':
      unless  => '/bin/bash -c "/usr/bin/id -nG jenkins-agent | /bin/grep -wq gpg-vault"',
      command => '/usr/sbin/usermod -aG gpg-vault jenkins-agent',
      require => [
        User['gpg-vault'],
        User['jenkins-agent'],
      ],
    }

    ['building', 'testing', 'main'].each |String $reponame| {
      exec {"init_ubuntu_${reponame}_repo":
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
          File['/var/repos', '/var/repos/ubuntu'],
          Package['python-yaml', 'python-configparser'],
        ]
      }
    }

    # needed for bootstrapping the repo
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

    if hiera('jenkins-agent::pulp_config', false) {
      class { 'pulp':
        data_dir => '/var/repos/.pulp',
        admin_password => hiera('jenkins-agent::pulp_config.admin_passphrase'),
        require => File['/var/repos'],
        gpg_socket => '/var/run/gpg-vault/S.gpg-agent',
        gpg_key_id => hiera('jenkins-agent::gpg_key_id'),
      }

      exec { 'gpg-vault-member-pulp':
        unless  => '/bin/bash -c "/usr/bin/id -nG pulp | /bin/grep -wq gpg-vault"',
        command => '/usr/sbin/usermod -aG gpg-vault pulp',
        require => [
          User['gpg-vault'],
          User['pulp'],
        ],
      }

      exec { 'pulp-gpg-init':
        path    => '/bin:/usr/bin:',
        command => 'gpg -K',
        unless  => 'test -d /home/pulp/.gnupg',
        user    => 'pulp',
        group   => 'pulp',
        require => User['pulp'],
      }
      -> file { '/home/pulp/.gnupg/gpg_public_key.pub':
        mode    => '0644',
        owner   => 'pulp',
        group   => 'pulp',
        content => hiera('jenkins-agent::gpg_public_key'),
      }
      ~> exec { 'pulp_import_gpg_public_key':
        path      => '/bin:/usr/bin:',
        command   => 'gpg --import /home/pulp/.gnupg/gpg_public_key.pub',
        user      => 'pulp',
        group     => 'pulp',
        unless    => "gpg --list-keys ${gpg_key_id}",
        logoutput => on_failure,
      }
      # Pulp requires that we trust our own public key
      ~> exec { 'pulp_trust_gpg_public_key':
        path      => '/bin:/usr/bin:',
        command   => "/bin/bash -c '(echo 5; echo y; echo save) | gpg --command-fd 0 --no-tty --no-greeting -q --edit-key ${gpg_key_id} trust'",
        user      => 'pulp',
        group     => 'pulp',
        unless    => "gpg2 --list-keys ${gpg_key_id} | grep -q '\\[ultimate\\]'",
        logoutput => on_failure,
      }

      if hiera('jenkins-agent::pulp_config.rpm', false) {
        hiera('jenkins-agent::pulp_config.rpm').each |String $distro_name, Hash $distro| {
          file { "/var/repos/${distro_name}":
            ensure => 'directory',
            owner  => $agent_username,
            group  => $agent_username,
            mode   => '0755',
            require => File['/var/repos'],
          }
          -> file { "/var/repos/${distro_name}/.htaccess":
            ensure => 'file',
            owner  => $agent_username,
            group  => $agent_username,
            mode   => '0644',
            content => epp('profile/rpm_repo_htaccess.epp', {'distro_name' => $distro_name}),
          }
          ['building', 'testing', 'main'].each |String $repo_name| {
            file { "/var/repos/${distro_name}/${repo_name}":
              ensure => 'directory',
              owner  => $agent_username,
              group  => $agent_username,
              mode   => '0755',
              require => File["/var/repos/${distro_name}"],
            }
          }

          $distro['versions'].each |String $distro_ver| {
            profile::ros::rpm_repo { "repo-${distro_name}-${distro_ver}":
              distro_name => $distro_name,
              distro_ver => $distro_ver,
              distro_arches => $distro['architectures'],
              gpg_key_id => hiera('jenkins-agent::gpg_key_id'),
            }
          }
        }
      }
    }
}
