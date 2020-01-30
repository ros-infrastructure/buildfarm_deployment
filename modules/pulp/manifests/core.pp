define pulp::core (
  $data_dir,
  $admin_password,
) {
  file { $data_dir:
    ensure => 'directory',
    owner  => 1000,
    mode   => '0700',
  }

  include docker

  docker::image {'pulp_image':
    ensure => 'latest',
    docker_dir => '/tmp/pulp/',
    require => [
      File['/tmp/pulp/Dockerfile'],
      File['/tmp/pulp/entry_point.sh'],
    ],
  }

  # Initialize and set the admin password
  # docker::run doesn't have a way to NOT detach, so we exec
  exec { 'pulp_init':
    path => ['/bin', '/usr/bin'],
    command => "docker run --rm -v ${data_dir}:/var/lib/pulp/data pulp_image django-admin reset-admin-password -p ${admin_password}",
    require => [
      File[$data_dir],
      Docker::Image['pulp_image'],
    ],
  }

  docker::run {'pulp':
    image => 'pulp_image',
    restart_service => true,
    volumes => ["${data_dir}:/var/lib/pulp/data"],
    ports => ['24816:24816', '24817:24817'],
    require => [
      File[$data_dir],
      Docker::Image['pulp_image'],
      Exec['pulp_init'],
    ],
  }
}
