# vim:ft=puppet

# Jenkins repoagent Profile
#
# Following the puppet convention of Roles and Profiles ([1]), create a profile
# class for operating a ROS Jenkins building_repository agent with the necessary files
# and dependencies.
#
# [1]: https://puppet.com/docs/pe/2017.3/managing_nodes/roles_and_profiles_example.html
class profile::jenkins::agent {
  class { 'rosjenkins::agent':
    agent_username => 'jenkins-repoagent',
  }
}


