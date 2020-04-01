define pulp::core (
  $data_dir,
  $admin_password,
) {
  user { 'pulp':
    ensure => present,
    managehome => true,
    uid => 1200,
  }

  file { $data_dir:
    ensure => 'directory',
    owner  => 'pulp',
    mode   => '0700',
    require => User['pulp'],
  }

  file { "${data_dir}/media":
    ensure => 'directory',
    owner => 'pulp',
    require => [
      File[$data_dir],
      User['pulp'],
    ],
  }

  #
  # Configure Redis
  #

  package { 'redis-server':
    ensure => present,
  }

  service { 'redis':
    name => 'redis-server',
    ensure => running,
    enable => true,
    require => Package['redis-server'],
  }

  exec { 'redis_config':
    path => ['/bin', '/usr/bin'],
    command => "sed -i -E -e 's|^#? ?port .*|port 0|' -e 's|^#? ?unixsocket .*|unixsocket /var/run/redis/redis.sock|' -e 's|^#? ?unixsocketperm .*|unixsocketperm 777|' /etc/redis/redis.conf",
    require => Package['redis-server'],
    notify => Service['redis'],
  }

  #
  # Configure Postgres
  #

  package { 'postgresql-server':
    name => 'postgresql',
    ensure => present,
  }

  service { 'postgresql':
    ensure => running,
    enable => true,
    require => Package['postgresql-server'],
  }

  exec { 'postgres_user':
    path => ['/bin', '/usr/bin'],
    command => 'psql -tc "SELECT 1 FROM pg_user WHERE usename = \'pulp\'" | grep -q 1 || psql -c "CREATE USER pulp WITH SUPERUSER LOGIN"',
    user => 'postgres',
    require => [
      Service['postgresql'],
      User['pulp'],
    ],
  }

  exec { 'postgres_db':
    path => ['/bin', '/usr/bin'],
    command => 'psql -tc "SELECT 1 FROM pg_database WHERE datname = \'pulp\'" | grep -q 1 || psql -c "CREATE DATABASE pulp OWNER pulp"',
    user => 'postgres',
    require => Exec['postgres_user'],
  }

  #
  # Build the Docker image
  #

  file { "${data_dir}/Dockerfile":
    ensure => 'file',
    source => 'puppet:///modules/pulp/Dockerfile',
    require => File[$data_dir],
  }

  include docker

  docker::image {'pulp_image':
    ensure => 'latest',
    docker_dir => $data_dir,
    require => [
      File["${data_dir}/Dockerfile"],
    ],
  }

  #
  # Initialize pulp
  #
  # Note that docker::run doesn't have a way to NOT detach, so we use Exec
  #

  # Django migrations
  exec { 'pulp_django_migration':
    path => ['/bin', '/usr/bin'],
    command => "docker run --user 1200 --rm -v /var/run/postgresql:/var/run/postgresql pulp_image pulpcore-manager migrate --noinput",
    require => [
      Docker::Image['pulp_image'],
      Exec['postgres_db'],
      User['pulp'],
    ],
  }

  # Reset the admin password
  exec { 'pulp_admin_pw':
    path => ['/bin', '/usr/bin'],
    command => "docker run --user 1200 --rm -v /var/run/postgresql:/var/run/postgresql pulp_image pulpcore-manager reset-admin-password -p ${admin_password}",
    require => [
      Docker::Image['pulp_image'],
      Exec['pulp_django_migration'],
      User['pulp'],
    ],
  }

  # Collect static content
  exec { 'pulp_collect_static':
    path => ['/bin', '/usr/bin'],
    command => "docker run --user 1200 --rm -v ${data_dir}:/var/repos/.pulp pulp_image pulpcore-manager collectstatic --noinput",
    require => [
      Docker::Image['pulp_image'],
      File[$data_dir],
      User['pulp'],
    ],
  }

  #
  # Configure pulp services
  #

  docker::run {'pulp_api':
    image => 'pulp_image',
    restart_service => true,
    volumes => [
      "${data_dir}:/var/repos/.pulp",
      "/var/run/postgresql:/var/run/postgresql",
      "/var/run/redis:/var/run/redis",
    ],
    ports => ['24817:24817'],
    username => '1200',
    command => 'pulpcore-manager runserver 0.0.0.0:24817',
    require => [
      Docker::Image['pulp_image'],
      Exec['pulp_admin_pw'],
      Exec['pulp_collect_static'],
      File[$data_dir],
      File["${data_dir}/media"],
      User['pulp'],
    ],
    depend_services => ['postgresql', 'redis-server'],
  }

  docker::run {'pulp_content':
    image => 'pulp_image',
    restart_service => true,
    volumes => [
      "${data_dir}:/var/repos/.pulp",
      "/var/run/postgresql:/var/run/postgresql",
      "/var/run/redis:/var/run/redis",
    ],
    ports => ['24816:24816'],
    username => '1200',
    command => 'pulp-content',
    require => [
      Docker::Image['pulp_image'],
      Exec['pulp_admin_pw'],
      Exec['pulp_collect_static'],
      File[$data_dir],
      User['pulp'],
    ],
    depend_services => ['postgresql', 'redis-server'],
  }

  docker::run {'pulp_rm':
    image => 'pulp_image',
    restart_service => true,
    volumes => [
      "${data_dir}:/var/repos/.pulp",
      "/var/run/postgresql:/var/run/postgresql",
      "/var/run/redis:/var/run/redis",
    ],
    username => '1200',
    command => "rq worker -n 'resource-manager' -w 'pulpcore.tasking.worker.PulpWorker' -c 'pulpcore.rqconfig'",
    require => [
      Docker::Image['pulp_image'],
      Exec['pulp_admin_pw'],
      Exec['pulp_collect_static'],
      File[$data_dir],
      User['pulp'],
    ],
    depend_services => ['postgresql', 'redis-server'],
  }

  ['1', '2'].each |String $worker_id| {
    docker::run {"pulp_worker_${worker_id}":
      image => 'pulp_image',
      restart_service => true,
      volumes => [
        "${data_dir}:/var/repos/.pulp",
        "/var/run/postgresql:/var/run/postgresql",
        "/var/run/redis:/var/run/redis",
      ],
      username => '1200',
      command => "rq worker -n pulp_worker_${worker_id} -w 'pulpcore.tasking.worker.PulpWorker' -c 'pulpcore.rqconfig'",
      require => [
        Docker::Image['pulp_image'],
        Exec['pulp_admin_pw'],
        Exec['pulp_collect_static'],
        File[$data_dir],
        User['pulp'],
      ],
      depend_services => ['postgresql', 'redis-server'],
    }
  }
}
