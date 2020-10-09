define pulp::rpm_repo(
  $repo_name = $title,
  $repo_endpoints = [$repo_name],
  $username = 'admin',
  $password = $pulp::admin_password,
  $base_url = 'http://127.0.0.1:24817',
  $gpg_key_id = undef,
) {
  if ($gpg_key_id) {
    $gpg_key_arg = "--signing-service-name '${gpg_key_id}'"
  }

  exec { "${title}_init_cmd":
    command => "python3 ${pulp::data_dir}/initialize.py ${gpg_key_arg} ${repo_name} ${repo_endpoints.join(' ')}",
    path => ['/bin', '/usr/bin'],
    environment => [
      "PULP_BASE_URL=${base_url}",
      "PULP_USERNAME=${username}",
      "PULP_PASSWORD=${password}",
    ],
    require => File["${pulp::data_dir}/initialize.py"],
  }
}
