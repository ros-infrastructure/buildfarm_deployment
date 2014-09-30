class { 'jenkins::slave':
  masterurl => 'http://master:8080',
  ui_user => 'johndoe',
  ui_pass => 'changeme',
  labels => "custom_labels",
  slave_mode => "exclusive",
  manage_slave_user => "1",
  executors => "1",
}