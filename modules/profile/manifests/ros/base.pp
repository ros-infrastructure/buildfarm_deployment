class profile::ros::base {

  # setup ntp with defaults
  include '::ntp'

  if hiera('repo::ip', false) {
    host {'repo':
      ip => hiera('repo::ip'),
    }
  }
  else {
    host {'repo':
      ensure => absent,
    }
  }

  if hiera('master::ip', false) {
    host {'master':
      ip => hiera('master::ip'),
    }
  }
  else {
    host {'master':
      ensure => absent,
    }
  }

  # bring in classes listed in hiera
  if hiera('classes', false) {
    hiera_include('classes')
  }

  # Setup generic ssh_keys
  if hiera('ssh_keys', false){
    $defaults = {
      'ensure' => 'present',
    }
    create_resources(ssh_authorized_key, hiera('ssh_keys'), $defaults)
  }
  else{
    notice("No ssh_keys defined. You should probably have at least one.")
  }


  if hiera('autoreconfigure') {
    cron {'autoreconfigure':
      environment => ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
      '],
      command => hiera('autoreconfigure::command'),
      user    => root,
      month   => absent,
      monthday => absent,
      hour    => absent,
      minute  => '*/15',
      weekday => absent,
    }
  }
  else {
    cron {'autoreconfigure':
      ensure => absent,
    }
  }
}

