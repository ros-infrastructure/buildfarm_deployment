class role::buildfarm::agent_gpu {
  # Find the other instances
  include profile::ros::base
  include profile::jenkins::agent
  include profile::jenkins::agent_gpu
}
