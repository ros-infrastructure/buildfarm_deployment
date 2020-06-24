class pulp (
  String           $data_dir       = $pulp::params::data_dir,
  Integer          $num_workers    = $pulp::params::num_workers,
  Optional[String] $admin_password = $pulp::params::admin_password,
) inherits pulp::params {
  user { 'pulp':
    ensure => present,
    managehome => true,
    uid => 1200,
  }
  -> file { $data_dir:
    ensure => 'directory',
    owner  => 'pulp',
    mode   => '0700',
  }
  -> file { "${data_dir}/media":
    ensure => 'directory',
    owner => 'pulp',
  }

  file { "${data_dir}/initialize.py":
    ensure => 'file',
    owner  => 'pulp',
    mode   => '0600',
    source => 'puppet:///modules/pulp/rpm_repo_init.py',
    require => File[$data_dir],
  }

  #
  # Configure Redis
  #

  package { 'redis-server':
    ensure => present,
  }
  -> exec { 'redis_config':
    path => ['/bin', '/usr/bin'],
    command => 'sed -i -E \
      -e "s|^#? ?port .*|port 0|" \
      -e "s|^#? ?unixsocket .*|unixsocket /var/run/redis/redis.sock|" \
      -e "s|^#? ?unixsocketperm .*|unixsocketperm 777|" \
      /etc/redis/redis.conf',
  }
  ~> service { 'redis':
    name => 'redis-server',
    ensure => running,
    enable => true,
    hasrestart => true,
  }

  #
  # Configure Postgres
  #

  package { 'postgresql-server':
    name => 'postgresql',
    ensure => present,
  }
  -> service { 'postgresql':
    ensure => running,
    enable => true,
    hasrestart => true,
  }
  -> exec { 'postgres_user':
    path => ['/bin', '/usr/bin'],
    command => 'psql -c "CREATE USER pulp WITH SUPERUSER LOGIN"',
    unless => 'psql -tc "SELECT 1 FROM pg_user WHERE usename = \'pulp\'" | grep -q 1',
    user => 'postgres',
    require => [
      User['pulp'],
    ],
  }
  -> exec { 'postgres_db':
    path => ['/bin', '/usr/bin'],
    command => 'psql -c "CREATE DATABASE pulp OWNER pulp"',
    unless => 'psql -tc "SELECT 1 FROM pg_database WHERE datname = \'pulp\'" | grep -q 1',
    user => 'postgres',
  }

  #
  # Build the Docker image
  #

  include docker

  file { "${data_dir}/Dockerfile":
    ensure => 'file',
    source => 'puppet:///modules/pulp/Dockerfile',
    require => File[$data_dir],
  }
  ~> docker::image {'pulp_image':
    ensure => 'latest',
    docker_dir => $data_dir,
    subscribe => File["${data_dir}/Dockerfile"],
  }

  #
  # Initialize pulp
  #
  # Note that docker::run doesn't have a way to NOT detach, so we use Exec
  #

  exec { 'pulp_django_migration':
    path => ['/bin', '/usr/bin'],
    command => "docker run --user 1200 --rm -v /var/run/postgresql:/var/run/postgresql pulp_image pulpcore-manager migrate --noinput",
    require => [
      Docker::Image['pulp_image'],
      Exec['postgres_db'],
      User['pulp'],
    ],
  }
  -> exec { 'pulp_collect_static':
    path => ['/bin', '/usr/bin'],
    command => "docker run --user 1200 --rm -v ${data_dir}:/var/repos/.pulp pulp_image pulpcore-manager collectstatic --noinput",
    require => [
      File[$data_dir],
    ],
  }

  if ($admin_password) {
    exec { 'pulp_admin_pw':
      path => ['/bin', '/usr/bin'],
      command => "docker run --user 1200 --rm -v /var/run/postgresql:/var/run/postgresql pulp_image pulpcore-manager reset-admin-password -p ${admin_password}",
    }
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

  range(1, $num_workers).each |Integer $worker_id| {
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
