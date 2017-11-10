# Run the entire buildfarm, repository and workers on a single host.
class role::buildfarm::standalone {
  include profile::ros::base
  include profile::jenkins::agent
  include profile::ros::repo
  include profile::jenkins::master
}
