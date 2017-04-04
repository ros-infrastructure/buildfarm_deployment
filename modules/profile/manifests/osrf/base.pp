class profile::osrf::base {
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

