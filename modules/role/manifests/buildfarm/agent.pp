class role::buildfarm::agent {
  # Find the other instances
  include profile::ros::base
  include profile::jenkins::agent

  if hiera('run_squid', false) {
    include profile::squidinacan
  }
}
