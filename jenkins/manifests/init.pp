include jenkins

include jenkins_files


## Jenkins Plugins
jenkins::plugin {
  "analysis-core" : ;
}

jenkins::plugin {
  "bazaar" : ;
}

jenkins::plugin {
  "build-timeout" : ;
}

jenkins::plugin {
  "collapsing-console-sections" : ;
}

# Config for collapsing console sections
file { "/var/lib/jenkins/org.jvnet.hudson.plugins.collapsingconsolesections.CollapsingSectionNote.xml":
    mode   => 640,
    owner  => jenkins,
    group  => jenkins,
    source => "puppet:///modules/jenkins_files/var/lib/jenkins/org.jvnet.hudson.plugins.collapsingconsolesections.CollapsingSectionNote.xml",
    require => Jenkins::Plugin['collapsing-console-sections'],
    notify => Service['jenkins'],
}

jenkins::plugin {
  "git" : ;
}

jenkins::plugin {
  "git-client" : ;
}

jenkins::plugin {
  "github-api" : ;
}

jenkins::plugin {
  "groovy-postbuild" : ;
}

jenkins::plugin {
  "mercurial" : ;
}

package {"mercurial":
  ensure => "installed",
}


jenkins::plugin {
  "PrioritySorter" : ;
}

jenkins::plugin {
  "scm-api" : ;
}

jenkins::plugin {
  "script-security" : ;
}

jenkins::plugin {
  "ssh-agent" : ;
}

jenkins::plugin {
  "subversion" : ;
}

jenkins::plugin {
  "swarm" : ;
}

jenkins::plugin {
  "token-macro" : ;
}

jenkins::plugin {
  "warnings" : ;
}


### Dependencies for Scripting
package {"python3-empy":
  ensure => "installed",
}

package {"python3-pip":
  ensure => "installed",
}

package {"python3-yaml":
  ensure => "installed",
}



# Add Chunking override to avoid cli errors
# https://issues.jenkins-ci.org/browse/JENKINS-23223
# from jenkins_files
file { "/etc/default/jenkins":
    mode   => 644,
    owner  => root,
    group  => root,
    source => "puppet:///modules/jenkins_files/etc/default/jenkins",
    require => Package['jenkins'],
    notify => Service['jenkins'],
}





# make sure that the config.xml is present.
# It does not get generated initially see https://github.com/ros-infrastructure/buildfarm_deployment/issues/2
# This is too strong, if puppet is rerun it will override any changed configs
file { "/var/lib/jenkins/config.xml":
  ensure => 'present',
  mode   => 640,
  owner  => jenkins,
  group  => jenkins,
  source => "puppet:///modules/jenkins_files/var/lib/jenkins/config.xml",
  require => Package['jenkins'],
  notify => Service['jenkins'],
}

$user_dirs = ["/var/lib/jenkins/users",
              "/var/lib/jenkins/users/admin"]

file { $user_dirs :
  ensure => 'directory',
  mode   => 640,
  owner  => jenkins,
  group  => jenkins,
}

# Create an admin user:
file { "/var/lib/jenkins/users/admin/config.xml":
  ensure => 'present',
  mode   => 640,
  owner  => jenkins,
  group  => jenkins,
  source => "puppet:///modules/jenkins_files/var/lib/jenkins/users/admin/config.xml",
  require => [Package['jenkins'],
              File[$user_dirs],],
  notify => Service['jenkins'],
}

class { 'python' :
  version    => 'system',
  pip        => true,
  dev        => true,
  virtualenv => true,
  gunicorn   => true,
}

python::pip { 'jenkinsapi' :

}


$buildfarm_config_dir = ["/var/lib/jenkins/.buildfarm"]

file { $buildfarm_config_dir :
  ensure => 'directory',
  mode   => 640,
  owner  => jenkins,
  group  => jenkins,
}

file { "/var/lib/jenkins/.buildfarm/jenkins.ini":
  ensure => 'present',
  mode   => 640,
  owner  => jenkins,
  group  => jenkins,
  source => "puppet:///modules/jenkins_files/var/lib/jenkins/.buildfarm/jenkins.ini",
  require => [Package['jenkins'],
              File[$buildfarm_config_dir],],
  notify => Service['jenkins'],
}

#Potential way to add new users if not doing raw config file manipulation
#exec {"wait for service":
#  require => Service["jenkins"],
#  command => "/bin/sleep 20 && /usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080",
#}

#jenkins::user {'johndoe':
#  email    => 'jdoe@example.com',
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
