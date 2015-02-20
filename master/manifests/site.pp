include apt

include jenkins

include jenkins_files

# setup ntp with defaults
include '::ntp'

# Needed by jenkins-slave to connect to the local master generically
if hiera('master::ip', false) {
  host {'master':
    ip => hiera('master::ip'),
  }
}
else {
  host {'master':
    ensure => absent,
  }
}
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

### Jenkins Slave
## Don't install java to avoid conflict with the master puppet formula
## https://github.com/jenkinsci/puppet-jenkins/issues/224
class { 'jenkins::slave':
  #labels => 'on_master',
  slave_mode => 'exclusive',
  slave_name => 'slave_on_master',
  slave_user => 'jenkins-slave',
  manage_slave_user => false,
  executors => '1',
  install_java => false,
  require => User['jenkins-slave'],
}

user{'jenkins-slave':
  ensure => present,
  managehome => true,
  groups => ['docker'],
  require => Package['lxc-docker']
}


$slave_buildfarm_config_dir = ['/home/jenkins-slave/.buildfarm']
file { $slave_buildfarm_config_dir:
  ensure => 'directory',
  mode => '0640',
  owner => jenkins-slave,
  group => jenkins-slave,
}

file { '/home/jenkins-slave/.buildfarm/jenkins.ini':
  ensure => 'present',
  mode => '0640',
  owner => jenkins-slave,
  group => jenkins-slave,
  content => template('jenkins_files/jenkins.ini.erb'),
  require => [User['jenkins-slave'],
              File[$slave_buildfarm_config_dir],],
  notify => Service['jenkins-slave'],
}

package { 'git':
  ensure => 'installed',
}

package { 'subversion':
  ensure => 'installed',
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
  'dashboard-view': ;
}

jenkins::plugin {
  'description-setter': ;
}

jenkins::plugin {
  'diskcheck': ;
}
# config for diskcheck
file { '/var/lib/jenkins/diskcheck.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/diskcheck.xml',
    require => Jenkins::Plugin['diskcheck'],
    notify => Service['jenkins'],
}

jenkins::plugin {
  'email-ext': ;
}

jenkins::plugin {
  'embeddable-build-status': ;
}

jenkins::plugin {
  'extra-columns': ;
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

# required by ghprb
jenkins::plugin {
  'github': ;
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

# required by subversion
jenkins::plugin {
  'mapdb-api': ;
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
  'pollscm': ;
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

jenkins::plugin {
  'purge-build-queue-plugin': ;
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

# required by cleanup_docker_images.py
package { 'python3-dateutil':
  ensure => 'installed',
}

# required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}

# required by subprocess reaper script
package { 'python3-psutil':
  ensure => 'installed',
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
  replace => false,
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

# For our convenience reading the logs
class { 'timezone':
  timezone => hiera('timezone', 'America/Los_Angeles'),
}



### install latest docker

class {'docker':
}

user { 'jenkins':
  name => 'jenkins',
  groups => ['jenkins', 'docker'],
  require => Package['docker'],
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

# Setup generic ssh_keys
if hiera('ssh_keys', false){
  $defaults = {
    'ensure' => 'present',
  }
  create_resources(ssh_authorized_key, hiera('ssh_keys'), $defaults)
}
else{
  notice("No ssh_authorized_keys defined. There should probably be at least one.")
}


# Reference above credientials
file { '/var/lib/jenkins/credentials.xml':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('jenkins_files/credentials.xml.erb'),
    require => File['/var/lib/jenkins/.ssh'],
}


if hiera('autoreconfigure') {
  cron {'autoreconfigure':
    environment => ['PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
'],
    command => hiera('autoreconfigure::command'),
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

# clean up containers and dangling images https://github.com/docker/docker/issues/928#issuecomment-58619854
cron {'docker_cleanup_images':
  command => 'bash -c "python3 -u /home/jenkins-slave/cleanup_docker_images.py"',
  user    => 'jenkins-slave',
  month   => absent,
  monthday => absent,
  hour    => '*/2',
  minute  => 15,
  weekday => absent,
  require => User['jenkins-slave'],
}


package { 'python3-pip':
 ensure => 'installed',
}
# required by cleanup_docker script
pip::install { 'docker-py':
  #package => 'jenkinsapi', # defaults to $title
  #version => '1.6', # if undef installs latest version
  python_version => '3', # defaults to 2.7
  #ensure => present, # defaults to present
  require => Package['python3-pip'],
}
