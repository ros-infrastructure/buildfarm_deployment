include jenkins



jenkins::plugin {
  "ansicolor" : ;
}

jenkins::plugin {
  "bazaar" : ;
}

jenkins::plugin {
  "build-timeout" : ;
}

jenkins::plugin {
  "git" : ;
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




#hack to wait for initialization of jenkins so the cli can interact with it. 
exec {"wait for service":
  require => Service["jenkins"],
  command => "/bin/sleep 20 && /usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080",
}

jenkins::user {'johndoe':
  email    => 'jdoe@example.com',
  password => 'changeme',
  require => Exec['wait for service'],
}

class {'jenkins::security':
  security_model => "full_control",
  require => [Exec['wait for service'], jenkins::user['johndoe'] ],
}
