# Netdata installation and configuration.
class netdata {
  file { '/tmp/netdata-kickstart.sh':
    source => 'puppet:///modules/netdata/netdata-kickstart.sh',
  }

  exec { 'install-netdata':
    command => '/tmp/netdata-kickstart.sh --no-updates --non-interactive',
    require => File['/tmp/netdata-kickstart.sh'],
    creates => '/usr/local/bin/netdata',
  }

  file { '/etc/systemd/system/netdata.service':
    source => 'puppet:///modules/netdata/netdata.service',
    notify =>  Exec['reload-systemd-daemons'],
  }

  exec { 'reload-systemd-daemons':
    command => '/bin/systemctl daemon-reload'
  }

  service {'netdata':
    ensure  => running,
    enable  => true,
    require =>  [File['/etc/systemd/system/netdata.service'],Exec['install-netdata']],
  }
}
