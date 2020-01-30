define pulp::rpm_repo(
  $repo_name = $title,
  $repo_endpoints = [$repo_name],
  $username = 'admin',
  $password = 'admin',
  $base_url = 'http://127.0.0.1:24817',
) {
  exec { "${title}_init_cmd":
    command => "python3 /tmp/pulp_rpm_repo/initialize.py ${repo_name} ${repo_endpoints.join(' ')}",
    path => ['/bin', '/usr/bin'],
    environment => [
      "PULP_BASE_URL=${base_url}",
      "PULP_USERNAME=${username}",
      "PULP_PASSWORD=${password}",
    ],
    require => File['/tmp/pulp_rpm_repo/initialize.py']
  }
}
