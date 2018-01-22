# rosjenkins::groovy
#
# A resource for running Groovy scripts via Jenkins CLI.
#
#
define rosjenkins::groovy(
  String $groovyfile = $title,
  String $jarfile = '/usr/share/jenkins/jenkins-cli.jar',
) {
  $jenkinsauth = "${::jenkins::slave::ui_user}:${::jenkins::slave::ui_pass}"

  exec { $title:
    provider => 'shell',
    command  => "java -jar $jarfile -s http://127.0.0.1:8080 -auth ${jenkinsauth} groovy = < $groovyfile",
    require  => [File[$jarfile, $groovyfile], Service['jenkins']],
  }
}

