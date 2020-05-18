# This module was automatically generated on 2019-01-22 11:09:04
# Instead of editing it, update plugins via the Jenkins web UI and rerun the generator.
# Otherwise your changes will be overwritten the next time it is run.
class profile::jenkins::rosplugins {
  ::jenkins::plugin { 'PrioritySorter':
    version => '3.6.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'] ]
  }

  ::jenkins::plugin { 'ace-editor':
    version => '1.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'analysis-core':
    version => '1.95',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['dashboard-view'], Jenkins::Plugin['git'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'ant':
    version => '1.9',
    require => [ Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'antisamy-markup-formatter':
    version => '1.5',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'apache-httpcomponents-client-4-api':
    version => '4.5.5-3.0',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'audit-trail':
    version => '2.3',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'badge':
    version => '1.6',
    require => [ Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'bazaar':
    version => '1.22',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'bouncycastle-api':
    version => '2.17',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'branch-api':
    version => '2.0.20',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'build-timeout':
    version => '1.19',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'cloudbees-folder':
    version => '6.6',
    require => [ Jenkins::Plugin['credentials'] ]
  }

  ::jenkins::plugin { 'collapsing-console-sections':
    version => '1.7.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jquery'] ]
  }

  ::jenkins::plugin { 'command-launcher':
    version => '1.2',
    require => [ Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['script-security'] ]
  }

  ::jenkins::plugin { 'conditional-buildstep':
    version => '1.3.6',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['run-condition'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'config-file-provider':
    version => '3.4.1',
    require => [ Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'copyartifact':
    version => '1.41',
    require => [ Jenkins::Plugin['apache-httpcomponents-client-4-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'cvs':
    version => '2.14',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jsch'] ]
  }

  ::jenkins::plugin { 'dashboard-view':
    version => '2.9.11',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'] ]
  }

  ::jenkins::plugin { 'description-setter':
    version => '1.10',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['matrix-project'] ]
  }

  ::jenkins::plugin { 'disable-failed-job':
    version => '1.15',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'display-url-api':
    version => '2.2.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'durable-task':
    version => '1.27',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'email-ext':
    version => '2.63',
    require => [ Jenkins::Plugin['analysis-core'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['config-file-provider'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'embeddable-build-status':
    version => '1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'external-monitor-job':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'extra-columns':
    version => '1.20',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['workflow-job'] ]
  }

  ::jenkins::plugin { 'ghprb':
    version => '1.42.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['git'], Jenkins::Plugin['github'], Jenkins::Plugin['github-api'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['plain-credentials'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'git':
    version => '3.9.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['git-client'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['parameterized-trigger'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'git-client':
    version => '2.7.3',
    require => [ Jenkins::Plugin['apache-httpcomponents-client-4-api'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jsch'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'git-server':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['git-client'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'github':
    version => '1.29.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['display-url-api'], Jenkins::Plugin['git'], Jenkins::Plugin['github-api'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['plain-credentials'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'github-api':
    version => '1.92',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jackson2-api'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'github-branch-source':
    version => '2.4.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['display-url-api'], Jenkins::Plugin['git'], Jenkins::Plugin['github'], Jenkins::Plugin['github-api'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'github-oauth':
    version => '0.29',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['git'], Jenkins::Plugin['github-api'], Jenkins::Plugin['github-branch-source'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['workflow-multibranch'] ]
  }

  ::jenkins::plugin { 'greenballs':
    version => '1.15',
    require => [ Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'groovy':
    version => '2.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['script-security'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'groovy-postbuild':
    version => '2.4.2',
    require => [ Jenkins::Plugin['badge'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['workflow-cps'] ]
  }

  ::jenkins::plugin { 'htmlpublisher':
    version => '1.21',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['trilead-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'icon-shim':
    version => '2.0.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'jackson2-api':
    version => '2.9.7.1',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'javadoc':
    version => '1.4',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'jdk-tool':
    version => '1.1',
    require => [  ]
  }

  ::jenkins::plugin { 'jobConfigHistory':
    version => '2.18.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'] ]
  }

  ::jenkins::plugin { 'jobrequeue':
    version => '1.1',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'jquery':
    version => '1.12.4-0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'jquery-detached':
    version => '1.2.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'jsch':
    version => '0.1.54.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['ssh-credentials'] ]
  }

  ::jenkins::plugin { 'junit':
    version => '1.26.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'ldap':
    version => '1.20',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['mailer'] ]
  }

  ::jenkins::plugin { 'log-parser':
    version => '2.1',
    require => [ Jenkins::Plugin['trilead-api'] ]
  }

  ::jenkins::plugin { 'mailer':
    version => '1.22',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['display-url-api'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'mapdb-api':
    version => '1.0.9.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'matrix-auth':
    version => '2.3',
    require => [ Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'matrix-project':
    version => '1.13',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['script-security'] ]
  }

  ::jenkins::plugin { 'maven-plugin':
    version => '3.1.2',
    require => [ Jenkins::Plugin['apache-httpcomponents-client-4-api'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jsch'], Jenkins::Plugin['junit'], Jenkins::Plugin['mailer'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'mercurial':
    version => '2.4',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jsch'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'monitoring':
    version => '1.74.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'pam-auth':
    version => '1.4',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'parameterized-trigger':
    version => '2.35.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['conditional-buildstep'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['script-security'], Jenkins::Plugin['subversion'] ]
  }

  ::jenkins::plugin { 'plain-credentials':
    version => '1.4',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'pollscm':
    version => '1.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'publish-over':
    version => '0.22',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'publish-over-ssh':
    version => '1.20.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['jsch'], Jenkins::Plugin['publish-over'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'purge-build-queue-plugin':
    version => '1.0',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'run-condition':
    version => '1.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'scm-api':
    version => '2.3.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'script-security':
    version => '1.48',
    require => [ Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'ssh-agent':
    version => '1.17',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'ssh-credentials':
    version => '1.14',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'ssh-slaves':
    version => '1.28.1',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['ssh-credentials'] ]
  }

  ::jenkins::plugin { 'structs':
    version => '1.20',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'subversion':
    version => '2.12.1',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['mapdb-api'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-scm-step'] ]
  }

  ::jenkins::plugin { 'systemloadaverage-monitor':
    version => '1.2',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'timestamper':
    version => '1.8.10',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'token-macro':
    version => '2.5',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'translation':
    version => '1.16',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'trilead-api':
    version => '1.0.4',
    require => [  ]
  }

  ::jenkins::plugin { 'warnings':
    version => '4.68',
    require => [ Jenkins::Plugin['analysis-core'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['dashboard-view'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'windows-slaves':
    version => '1.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'] ]
  }

  ::jenkins::plugin { 'workflow-api':
    version => '2.31',
    require => [ Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'workflow-cps':
    version => '2.60',
    require => [ Jenkins::Plugin['ace-editor'], Jenkins::Plugin['jquery-detached'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-cps-global-lib':
    version => '2.12',
    require => [ Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['credentials'], Jenkins::Plugin['git-client'], Jenkins::Plugin['git-server'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-scm-step'] ]
  }

  ::jenkins::plugin { 'workflow-job':
    version => '2.28',
    require => [ Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-multibranch':
    version => '2.20',
    require => [ Jenkins::Plugin['branch-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-scm-step':
    version => '2.7',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'workflow-step-api':
    version => '2.16',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'workflow-support':
    version => '2.22',
    require => [ Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'xunit':
    version => '2.3.1',
    require => [ Jenkins::Plugin['command-launcher'], Jenkins::Plugin['jdk-tool'], Jenkins::Plugin['junit'], Jenkins::Plugin['structs'] ]
  }

}
