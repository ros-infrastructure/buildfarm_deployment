include apt

include jenkins

include jenkins_files

include pip


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
  'mercurial': ;
}
package { 'mercurial':
  ensure => 'installed',
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
  'swarm': ;
}

# required by build-timeout
jenkins::plugin {
  'token-macro': ;
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

$user_dirs = ['/var/lib/jenkins/users',
              '/var/lib/jenkins/users/admin']

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
  #source => 'puppet:///modules/jenkins_files/var/lib/jenkins/users/admin/config.xml',
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
  source => 'puppet:///modules/jenkins_files/var/lib/jenkins/.buildfarm/jenkins.ini',
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

# change docker storage driver
file { '/etc/default/docker':
    mode => '0644',
    owner => root,
    group => root,
    source => 'puppet:///modules/jenkins_files/etc/default/docker',
    require => Package['lxc-docker'],
}

file { '/var/lib/jenkins/.ssh':
    ensure => 'directory',
    owner  => 'jenkins',
    group  => 'jenkins',
    mode   => '0700',
    require => User['jenkins'],
}

# TODO make this parameterized. This is a hack to get up and running on
# the local development machines only!!!!!!
# add ssh key
file { '/var/lib/jenkins/.ssh/id_rsa':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/.ssh/id_rsa',
    require => File['/var/lib/jenkins/.ssh'],
}
file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/.ssh/id_rsa.pub',
    require => File['/var/lib/jenkins/.ssh'],
}

# Reference above credientials
file { '/var/lib/jenkins/credentials.xml':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/credentials.xml',
    require => File['/var/lib/jenkins/.ssh'],
}


#Potential way to add new users if not doing raw config file manipulation
#exec {"wait for service":
#  require => Service["jenkins"],
#  command => "/bin/sleep 20 && /usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080",
#}

#jenkins::user {'johndoe':
#  email => 'jdoe@example.com',
#  password => 'changeme',
#  full_name => "John Doe Test User",
#  require => [Exec['wait for service'],
#              File["/etc/default/jenkins"],
#              ]
#}


# Old work for trying to work around #2
#class {'jenkins::security':
#  security_model => "full_control",
#  require => [Exec['wait for service'], Jenkins::User['johndoe'] ],
#  notify => Exec['safe_restart'],
#}

#exec {"safe_restart":
#  command => "/bin/sleep 10 && /usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080 safe-restart --username johndoe --password changeme && sleep 30",
#}
