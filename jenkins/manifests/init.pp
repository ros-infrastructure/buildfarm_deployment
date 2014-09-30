include jenkins

include jenkins_files

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

#hack to wait for initialization of jenkins so the cli can interact with it. 
exec {"wait for service":
  require => Service["jenkins"],
  command => "/bin/sleep 20 && /usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080",
}

jenkins::user {'johndoe':
  email    => 'jdoe@example.com',
  password => 'changeme',
  require => [Exec['wait for service'],
              File["/etc/default/jenkins"],
              ]
}

class {'jenkins::security':
  security_model => "full_control",
  require => [Exec['wait for service'], Jenkins::User['johndoe'] ],
  notify => Exec['safe_restart'],
}

exec {"safe_restart":
  command => "/bin/sleep 10 && /usr/bin/java -jar /usr/share/jenkins/jenkins-cli.jar -s http://localhost:8080 safe-restart --username johndoe --password changeme && sleep 30",
}