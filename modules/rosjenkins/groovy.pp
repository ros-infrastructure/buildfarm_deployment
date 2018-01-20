# rosjenkins::groovy
#
# A resource for running Groovy scripts via Jenkins CLI.
#
#
define rosjenkins::groovy(
  String $groovyfile = $title,
  String $jarfile = '/usr/share/jenkins/jenkins-cli.jar',
) {

  exec { $title:
    provider => 'shell',
    command  => "java -jar $jarfile -s http://127.0.0.1:8080 groovy $groovyfile",
    require  => File[$jarfile, $groovyfile],
  }
}

