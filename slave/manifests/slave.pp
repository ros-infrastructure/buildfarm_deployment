class { 'jenkins::slave':
  labels => 'docker',
  slave_mode => "exclusive",
  slave_user => 'jenkins-slave',
  manage_slave_user => "1",
  executors => "1",
}
