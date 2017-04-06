class profile::squidinacan {
  docker::image {'jpetazzo/squid-in-a-can':
    require => Package['docker'],
  }

  file { '/var/cache/squid-in-a-can' :
    ensure => 'directory',
    mode   => '0644',
    owner  => 'proxy',
    group  => 'proxy',
  }

  file { '/var/log/squid-in-a-can' :
    ensure => 'directory',
    mode   => '0644',
    owner  => 'proxy',
    group  => 'proxy',
  }

  $disk_cache_size = hiera('squid-in-a-can::max_cache_size', 5000)
  $max_cache_object = hiera('squid-in-a-can::max_cache_object', 1000)
  docker::run {'squid-in-a-can':
    image   => 'jpetazzo/squid-in-a-can',
    command => '/tmp/deploy_squid.py',
    env     => ["DISK_CACHE_SIZE=${disk_cache_size}",
                "MAX_CACHE_OBJECT=${max_cache_object}",
                'SQUID_DIRECTIVES=\'
refresh_pattern . 0 0 1 refresh-ims
refresh_all_ims on # make sure we do not get out of date content #41
ignore_expect_100 on # needed for new relic system monitor
\''],
    volumes => ['/var/cache/squid-in-a-can:/var/cache/squid3',
                '/var/log/squid-in-a-can:/var/log/squid3',
                ],
    net     => 'host',
    require => [Docker::Image['jpetazzo/squid-in-a-can'],
      File['/var/cache/squid-in-a-can'],
      File['/var/log/squid-in-a-can'],
    ],
  }

  file { '/home/jenkins-agent/manage.py':
    ensure => present,
    source => 'puppet:///modules/agent_files/home/jenkins-agent/manage.py',
    mode => '0755',
  }

  upstart::job{'manage-tproxy':
    description => 'Manage iptables for tproxy',
    chdir       => '/home/jenkins-agent',
    exec        => '/home/jenkins-agent/manage.py',
    require     => File[ '/home/jenkins-agent/manage.py'],
    respawn     => true,
    respawn_limit => '99 5',
  }
}
