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


#jenkins::security { "jsecurity":
#  security_model => 'full_control',
#}

#jenkins::user {'johndoe':
#  email    => 'jdoe@example.com',
#  password => 'changeme',
#}


## In puppet:
#anchor {'jenkins-bootstrap-start': } ->
#  Class['jenkins::cli_helper'] ->
#    Exec[foobar]->
#        anchor {'jenkins-bootstrap-complete': }

#exec {"foobar":
#     command => 'service jenkins start',
#     path    => "/usr/local/bin/:/bin/",
#}