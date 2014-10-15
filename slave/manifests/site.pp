import 'slave.pp'

package {'docker.io':
  ensure => 'installed',
}

# required by jobs to generate Dockerfiles
package { 'python3-empy':
  ensure => 'installed',
}
