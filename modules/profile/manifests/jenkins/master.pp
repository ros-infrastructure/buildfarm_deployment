# Jenkins master Profile
#
# Following the puppet convention of Roles and Profiles ([1]), create a profile
# class for operating a Jenkins master/manager with the necessary plugins to
# run the ROS buildfarm.
#
# [1]: https://puppet.com/docs/pe/2017.3/managing_nodes/roles_and_profiles_example.html
class profile::jenkins::master {
  include rosjenkins::manager
  include profile::jenkins::agent

  ### install latest docker
  include docker

  # Add jenkins user to docker group if not already
  # That this needs to be done with a command rather than a resource declaration is a side effect of the 'jenkins'
  # user being managed by the jenkins module.
  # If future alterations are necessary it may be worth managing the user ourselves.
  exec {'jenkins docker membership':
    unless => '/bin/bash -c "/usr/bin/id -nG jenkins | /bin/grep -wq docker"',
    command => '/usr/sbin/usermod -aG docker jenkins',
    require => User['jenkins'],
  }
  include rosapache
  apache::vhost { 'master':
    docroot => '/var/www.html',
    port    => '80',
    proxy_pass => [
      { 'path' => '/', 'url' => 'http://localhost:8080/'},
    ],
  }
}
