class profile::jenkins::master {
  include ::jenkins
  include ::jenkins::master
  include profile::jenkins::rosplugins
  include profile::jenkins::agent

  include jenkins_files

  ### Jenkins Plugins

  # config for gitscm
  jenkins::cli::exec { 'configure_git_user':
    # semicolons are needed because the lines are joined with spaces rather than newlines.
    command => [
      'def gitscm_config = Jenkins.getInstance().getDescriptor("hudson.plugins.git.GitSCM");',
      'gitscm_config.setCreateAccountBasedOnEmail(false);',
      'gitscm_config.setGlobalConfigName("jenkins");',
      'gitscm_config.setGlobalConfigEmail("jenkins@build.ros.org");',
      'gitscm_config.save();',
    ]
  }

  # config for audit-trail
  file { '/var/lib/jenkins/audit-trail.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/audit-trail.xml',
    require => Jenkins::Plugin['audit-trail'],
    notify => Service['jenkins'],
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

  # config for jobConfigHistory
  file { '/var/lib/jenkins/jobConfigHistory.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/jobConfigHistory.xml',
    require => Jenkins::Plugin['jobConfigHistory'],
    notify => Service['jenkins'],
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

  # config for publish-over-ssh
  file { '/var/lib/jenkins/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    content => template('jenkins_files/jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml.erb'),
    require => Jenkins::Plugin['publish-over-ssh'],
    notify => Service['jenkins'],
  }

  # config for subversion
  file { '/var/lib/jenkins/hudson.scm.SubversionSCM.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/hudson.scm.SubversionSCM.xml',
    require => Jenkins::Plugin['subversion'],
    notify => Service['jenkins'],
  }

  # config for warnings
  file { '/var/lib/jenkins/hudson.plugins.warnings.WarningsPublisher.xml':
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/hudson.plugins.warnings.WarningsPublisher.xml',
    require => Jenkins::Plugin['warnings'],
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

  # Use default mercurial, but enable caching.
  # Otherwise if the workspace is lost mercurial will trigger a job
  # whenever it tries to poll.
  file { '/var/lib/jenkins/hudson.plugins.mercurial.MercurialInstallation.xml':
    ensure => 'present',
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/hudson.plugins.mercurial.MercurialInstallation.xml',
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

  file { '/var/lib/jenkins/scriptApproval.xml':
    ensure  => 'present',
    mode    => '0640',
    owner   => jenkins,
    group   => jenkins,
    source  => 'puppet:///modules/jenkins_files/var/lib/jenkins/scriptApproval.xml',
    require => Package['jenkins'],
    notify  => Service['jenkins'],
  }

  $user_dirs = ['/var/lib/jenkins/users',
  '/var/lib/jenkins/users/admin',
  '/var/lib/jenkins/secrets',
  '/var/lib/jenkins/secrets/filepath-filters.d',
  ]

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
    require => [Package['jenkins'],
    File[$user_dirs],],
    notify => Service['jenkins'],
  }

  # Give access to ssh_id to slaves
  file { '/var/lib/jenkins/secrets/filepath-filters.d/60-ssh-id.conf':
    ensure => 'present',
    mode => '0640',
    owner => jenkins,
    group => jenkins,
    source => 'puppet:///modules/jenkins_files/var/lib/jenkins/secrets/filepath-filters.d/60-ssh-id.conf',
    require => [Package['jenkins'],
    File[$user_dirs],],
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

  # For our convenience reading the logs
  class { 'timezone':
    timezone => hiera('timezone', 'America/Los_Angeles'),
  }

  # setup apache
  class { 'apache':
    default_vhost => false,
  }

  apache::vhost { 'master':
    docroot => '/var/www.html',
    port    => '80',
    proxy_pass => [
      { 'path' => '/', 'url' => 'http://localhost:8080/'},
    ],
  }

  # required by management jobs to read rosdistro yaml files
  package { 'python3-yaml':
    ensure => 'installed',
  }


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

  ## Credentials necessar for Publish over SSH
  ## Everything else uses the built in credentials
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

  # Reference above credientials
  file { '/var/lib/jenkins/credentials.xml':
    mode => '0600',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('jenkins_files/credentials.xml.erb'),
  }
}
