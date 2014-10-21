class { 'jenkins::slave':
  labels => "building_repository",
  slave_mode => "exclusive",
  slave_name => 'building_repository',
  manage_slave_user => true,
  executors => "1",
}
