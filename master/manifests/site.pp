include apt

include jenkins

include jenkins_files

include pip

# setup ntp with defaults
include '::ntp'

# Find the other instances
if hiera('repo::ip', false) {
  host {'repo':
    ip => hiera('repo::ip'),
  }
}
else {
  host {'repo':
    ensure => absent,
  }
}

### Jenkins Plugins

jenkins::plugin {
  'bazaar': ;
}

package { 'bzr':
  ensure => 'installed',
}

jenkins::plugin {
  'build-timeout': ;
}

jenkins::plugin {
  'collapsing-console-sections': ;
}
# config for collapsing-console-sections
file { '/var/lib/jenkins/org.jvnet.hudson.plugins.collapsingconsolesections.CollapsingSectionNote.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/org.jvnet.hudson.plugins.collapsingconsolesections.CollapsingSectionNote.xml',
    require => Jenkins::Plugin['collapsing-console-sections'],
    notify => Service['jenkins'],
}

jenkins::plugin {
  'copyartifact': ;
}

jenkins::plugin {
  'description-setter': ;
}

jenkins::plugin {
  'ghprb': ;
}
# config for auto-managing github web hooks
file { '/var/lib/jenkins/com.cloudbees.jenkins.GitHubPushTrigger.xml':
    ensure => 'present',
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('jenkins_files/com.cloudbees.jenkins.GitHubPushTrigger.xml.erb'),
    require => Package['jenkins'],
    notify => Service['jenkins'],
}
# config for ghprb
file { '/var/lib/jenkins/org.jenkinsci.plugins.ghprb.GhprbTrigger.xml':
    ensure => 'present',
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('jenkins_files/org.jenkinsci.plugins.ghprb.GhprbTrigger.xml.erb'),
    require => Package['jenkins'],
    notify => Service['jenkins'],
}

# required by ghprb
jenkins::plugin {
  'git': ;
}

jenkins::plugin {
  'git-client': ;
}

jenkins::plugin {
  'github-api': ;
}

jenkins::plugin {
  'greenballs': ;
}

jenkins::plugin {
  'groovy': ;
}

jenkins::plugin {
  'groovy-postbuild': ;
}

jenkins::plugin {
  'jobrequeue': ;
}

jenkins::plugin {
  'mercurial': ;
}

package { 'mercurial':
  ensure => 'installed',
}

jenkins::plugin {
  'monitoring': ;
}

jenkins::plugin {
  'parameterized-trigger': ;
}

jenkins::plugin {
  'PrioritySorter': ;
}
# config for PrioritySorter
file { '/var/lib/jenkins/jenkins.advancedqueue.PrioritySorterConfiguration.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/jenkins.advancedqueue.PrioritySorterConfiguration.xml',
    require => Jenkins::Plugin['PrioritySorter'],
    notify => Service['jenkins'],
}

jenkins::plugin {
  'publish-over-ssh': ;
}
# config for publish-over-ssh
file { '/var/lib/jenkins/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml',
    require => Jenkins::Plugin['publish-over-ssh'],
    notify => Service['jenkins'],
}

# required by mercurial
jenkins::plugin {
  'scm-api': ;
}

# required by groovy-postbuild
jenkins::plugin {
  'script-security': ;
}

jenkins::plugin {
  'ssh-agent': ;
}

jenkins::plugin {
  'subversion': ;
}

jenkins::plugin {
  'systemloadaverage-monitor': ;
}

jenkins::plugin {
  'swarm': ;
}

jenkins::plugin {
  'timestamper': ;
}

# required by build-timeout
jenkins::plugin {
  'token-macro': ;
}

jenkins::plugin {
  'writable-filesystem-monitor': ;
}

jenkins::plugin {
  'xunit': ;
}


### Dependencies for Scripting

# required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}

# required by management jobs to manipulate Jenkins jobs
package { 'python3-pip':
  ensure => 'installed',
}
pip::install { 'jenkinsapi':
  python_version => '3',    # defaults to 2.7
  require => Package['python3-pip'],
}

# required by management jobs to read rosdistro yaml files
package { 'python3-yaml':
  ensure => 'installed',
}


# Add Chunking override to avoid cli errors
# https://issues.jenkins-ci.org/browse/JENKINS-23223
# from jenkins_files
file { '/etc/default/jenkins':
    mode => '0644',
    owner => root,
    group => root,
    source => 'puppet:///modules/jenkins_files/etc/default/jenkins',
    require => Package['jenkins'],
    notify => Service['jenkins'],
}


# make sure that the config.xml is present.
# It does not get generated initially see https://github.com/ros-infrastructure/buildfarm_deployment/issues/2
# This is too strong, if puppet is rerun it will override any changed configs
file { '/var/lib/jenkins/config.xml':
  ensure => 'present',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
  source => 'puppet:///modules/jenkins_files/var/lib/jenkins/config.xml',
  require => Package['jenkins'],
  notify => Service['jenkins'],
}

file { '/var/lib/jenkins/nodeMonitors.xml':
  ensure => 'present',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
  content => template('jenkins_files/nodeMonitors.xml.erb'),
  require => Package['jenkins'],
  notify => Service['jenkins'],
}

$user_dirs = ['/var/lib/jenkins/users',
              '/var/lib/jenkins/users/admin',
              '/var/lib/jenkins/secrets',]

file { $user_dirs:
  ensure => 'directory',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
}


# enable slave -> master access control
file { '/var/lib/jenkins/secrets/slave-to-master-security-kill-switch':
  ensure => 'present',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
  source => 'puppet:///modules/jenkins_files/var/lib/jenkins/secrets/slave-to-master-security-kill-switch',
  require => Package['jenkins'],
  notify => Service['jenkins'],
}


# Create an admin user:
file { '/var/lib/jenkins/users/admin/config.xml':
  ensure => 'present',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
  content => template('jenkins_files/user_config.xml.erb'),
  require => [Package['jenkins'],
              File[$user_dirs],],
  notify => Service['jenkins'],
}

$buildfarm_config_dir = ['/var/lib/jenkins/.buildfarm']
file { $buildfarm_config_dir:
  ensure => 'directory',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
}
file { '/var/lib/jenkins/.buildfarm/jenkins.ini':
  ensure => 'present',
  mode => '0640',
  owner => jenkins,
  group => jenkins,
  content => template('jenkins_files/jenkins.ini.erb'),
  require => [Package['jenkins'],
              File[$buildfarm_config_dir],],
  notify => Service['jenkins'],
}


### install latest docker

package { 'apt-transport-https':
  ensure => 'installed',
}

apt::source { 'docker':
  location => 'https://get.docker.com/ubuntu',
  release => 'docker',
  repos => 'main',
  key => 'A88D21E9',
  key_server => 'keyserver.ubuntu.com',
  include_src => false,
  require => Package['apt-transport-https'],
}

package { 'lxc-docker':
  ensure => 'installed',
  require => Apt::Source['docker'],
}
user { 'jenkins':
  name => 'jenkins',
  groups => ['jenkins', 'docker'],
  require => Package['lxc-docker'],
}

file { '/var/lib/jenkins/.ssh':
    ensure => 'directory',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0700',
    require => User['jenkins'],
}

# add ssh key
file { '/var/lib/jenkins/.ssh/id_rsa':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => hiera('jenkins::private_ssh_key'),
    require => File['/var/lib/jenkins/.ssh'],
}
file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => hiera('jenkins::authorized_keys'),
    require => File['/var/lib/jenkins/.ssh'],
}

# Reference above credientials
file { '/var/lib/jenkins/credentials.xml':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('jenkins_files/credentials.xml.erb'),
    require => File['/var/lib/jenkins/.ssh'],
}

# use wrapdocker from dind
file { '/var/lib/jenkins/wrapdocker':
    mode => '0770',
    owner => 'jenkins',
    group => 'jenkins',
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/wrapdocker',
    require => User['jenkins'],
}

## wrapdocker requires apparmor to avoid this error:
# Error loading docker apparmor profile: fork/exec /sbin/apparmor_parser: no such file or directory ()
# https://github.com/docker/docker/issues/4734
package { 'apparmor':
  ensure => 'installed',
}

if hiera('autoreconfigure') {
  $autoreconf_key = 'AUTORECONFIGURE_UPSTREAM_BRANCH='
  $branch_str = hiera('autoreconfigure::branch')
  $env_str = "$autoreconf_key$branch_str"
  cron {'autoreconfigure':
    environment => [$env_str,
                    'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
'],
    command => 'bash -c "cd /root/buildfarm_deployment && git fetch origin && git reset --hard $AUTORECONFIGURE_UPSTREAM_BRANCH && cd master && ./deploy.bash"',
    user    => root,
    month   => absent,
    monthday => absent,
    hour    => absent,
    minute  => '*/15',
    weekday => absent,
  }
}
else {
  cron {'autoreconfigure':
    ensure => absent,
  }
}
