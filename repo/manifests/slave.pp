class { 'jenkins::slave':
  masterurl => 'http://master:8080',
  ui_user => 'admin',
  ui_pass => 'changeme',
  labels => "building_repository",
  slave_mode => "exclusive",
  slave_name => 'building_repository',
  slave_user => 'jenkins-slave',
  manage_slave_user => "1",
  executors => "1",
}
