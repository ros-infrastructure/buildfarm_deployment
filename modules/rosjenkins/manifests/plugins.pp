# This module was automatically generated on 2017-08-28 11:59:04
# Instead of editing it, update plugins via the Jenkins web UI and rerun the generator.
# Otherwise your changes will be overwritten the next time it is run.
class profile::jenkins::rosplugins {
  ::jenkins::plugin { 'PrioritySorter':
    version => '3.5.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['workflow-durable-task-step'] ]
  }

  ::jenkins::plugin { 'ace-editor':
    version => '1.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'analysis-core':
    version => '1.92',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['dashboard-view'], Jenkins::Plugin['git'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'ant':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'antisamy-markup-formatter':
    version => '1.5',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'audit-trail':
    version => '2.2',
    require => [ Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'authentication-tokens':
    version => '1.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'] ]
  }

  ::jenkins::plugin { 'bazaar':
    version => '1.22',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'bouncycastle-api':
    version => '2.16.2',
    require => [  ]
  }

  ::jenkins::plugin { 'branch-api':
    version => '2.0.11',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'build-timeout':
    version => '1.18',
    require => [ Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'cloudbees-folder':
    version => '6.1.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'] ]
  }

  ::jenkins::plugin { 'collapsing-console-sections':
    version => '1.6.0',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'conditional-buildstep':
    version => '1.3.6',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['run-condition'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'copyartifact':
    version => '1.38.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'] ]
  }

  ::jenkins::plugin { 'credentials-binding':
    version => '1.13',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['plain-credentials'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'cvs':
    version => '2.13',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'dashboard-view':
    version => '2.9.11',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'] ]
  }

  ::jenkins::plugin { 'description-setter':
    version => '1.10',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'], Jenkins::Plugin['matrix-project'] ]
  }

  ::jenkins::plugin { 'disable-failed-job':
    version => '1.15',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'display-url-api':
    version => '2.0',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'docker-commons':
    version => '1.8',
    require => [ Jenkins::Plugin['authentication-tokens'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['credentials-binding'], Jenkins::Plugin['icon-shim'] ]
  }

  ::jenkins::plugin { 'docker-workflow':
    version => '1.12',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['docker-commons'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-durable-task-step'] ]
  }

  ::jenkins::plugin { 'durable-task':
    version => '1.14',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'email-ext':
    version => '2.58',
    require => [ Jenkins::Plugin['analysis-core'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['script-security'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'embeddable-build-status':
    version => '1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'external-monitor-job':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'extra-columns':
    version => '1.18',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'ghprb':
    version => '1.39.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['git'], Jenkins::Plugin['github'], Jenkins::Plugin['github-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['plain-credentials'], Jenkins::Plugin['ssh-agent'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'git':
    version => '3.5.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['git-client'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['parameterized-trigger'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['workflow-scm-step'] ]
  }

  ::jenkins::plugin { 'git-client':
    version => '2.5.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'git-server':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['git-client'] ]
  }

  ::jenkins::plugin { 'github':
    version => '1.28.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['display-url-api'], Jenkins::Plugin['git'], Jenkins::Plugin['github-api'], Jenkins::Plugin['plain-credentials'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'github-api':
    version => '1.86',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['jackson2-api'] ]
  }

  ::jenkins::plugin { 'github-branch-source':
    version => '2.2.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['display-url-api'], Jenkins::Plugin['git'], Jenkins::Plugin['github'], Jenkins::Plugin['github-api'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'github-oauth':
    version => '0.27',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['git'], Jenkins::Plugin['github-api'], Jenkins::Plugin['github-branch-source'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['workflow-multibranch'] ]
  }

  ::jenkins::plugin { 'greenballs':
    version => '1.15',
    require => [ Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'groovy':
    version => '2.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'groovy-postbuild':
    version => '2.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['script-security'], Jenkins::Plugin['workflow-cps'] ]
  }

  ::jenkins::plugin { 'handlebars':
    version => '1.1.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'icon-shim':
    version => '2.0.3',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'jackson2-api':
    version => '2.7.3',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'javadoc':
    version => '1.4',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'jobConfigHistory':
    version => '2.17',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'] ]
  }

  ::jenkins::plugin { 'jobrequeue':
    version => '1.1',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'jquery-detached':
    version => '1.2.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'junit':
    version => '1.21',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'ldap':
    version => '1.16',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['mailer'] ]
  }

  ::jenkins::plugin { 'mailer':
    version => '1.20',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['display-url-api'] ]
  }

  ::jenkins::plugin { 'mapdb-api':
    version => '1.0.9.0',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'matrix-auth':
    version => '1.7',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['icon-shim'] ]
  }

  ::jenkins::plugin { 'matrix-project':
    version => '1.11',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'], Jenkins::Plugin['script-security'] ]
  }

  ::jenkins::plugin { 'maven-plugin':
    version => '2.17',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['mailer'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'mercurial':
    version => '2.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'momentjs':
    version => '1.1.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'monitoring':
    version => '1.69.0',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'pam-auth':
    version => '1.3',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'] ]
  }

  ::jenkins::plugin { 'parameterized-trigger':
    version => '2.35.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['conditional-buildstep'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['subversion'] ]
  }

  ::jenkins::plugin { 'pipeline-build-step':
    version => '2.5.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'pipeline-graph-analysis':
    version => '1.5',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['pipeline-input-step'], Jenkins::Plugin['pipeline-stage-step'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'pipeline-input-step':
    version => '2.8',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'pipeline-milestone-step':
    version => '1.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'pipeline-model-api':
    version => '1.1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'pipeline-model-declarative-agent':
    version => '1.1.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['pipeline-model-extensions'] ]
  }

  ::jenkins::plugin { 'pipeline-model-definition':
    version => '1.1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials-binding'], Jenkins::Plugin['docker-workflow'], Jenkins::Plugin['pipeline-model-api'], Jenkins::Plugin['pipeline-model-declarative-agent'], Jenkins::Plugin['pipeline-model-extensions'], Jenkins::Plugin['pipeline-stage-step'], Jenkins::Plugin['pipeline-stage-tags-metadata'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-basic-steps'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-cps-global-lib'], Jenkins::Plugin['workflow-durable-task-step'], Jenkins::Plugin['workflow-multibranch'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'pipeline-model-extensions':
    version => '1.1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['pipeline-model-api'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-job'] ]
  }

  ::jenkins::plugin { 'pipeline-rest-api':
    version => '2.8',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['pipeline-graph-analysis'], Jenkins::Plugin['pipeline-input-step'], Jenkins::Plugin['pipeline-stage-step'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'pipeline-stage-step':
    version => '2.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'pipeline-stage-tags-metadata':
    version => '1.1.9',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'pipeline-stage-view':
    version => '2.8',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['handlebars'], Jenkins::Plugin['jquery-detached'], Jenkins::Plugin['momentjs'], Jenkins::Plugin['pipeline-rest-api'], Jenkins::Plugin['workflow-job'] ]
  }

  ::jenkins::plugin { 'plain-credentials':
    version => '1.4',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'] ]
  }

  ::jenkins::plugin { 'pollscm':
    version => '1.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'publish-over-ssh':
    version => '1.17',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'purge-build-queue-plugin':
    version => '1.0',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'run-condition':
    version => '1.0',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['token-macro'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'scm-api':
    version => '2.2.1',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'script-security':
    version => '1.33',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'ssh-agent':
    version => '1.15',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'ssh-credentials':
    version => '1.13',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'] ]
  }

  ::jenkins::plugin { 'ssh-slaves':
    version => '1.21',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['ssh-credentials'] ]
  }

  ::jenkins::plugin { 'structs':
    version => '1.10',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'subversion':
    version => '2.9',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['credentials'], Jenkins::Plugin['mapdb-api'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['ssh-credentials'], Jenkins::Plugin['workflow-scm-step'] ]
  }

  ::jenkins::plugin { 'systemloadaverage-monitor':
    version => '1.2',
    require => [ Jenkins::Plugin['ant'], Jenkins::Plugin['antisamy-markup-formatter'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['external-monitor-job'], Jenkins::Plugin['javadoc'], Jenkins::Plugin['junit'], Jenkins::Plugin['ldap'], Jenkins::Plugin['mailer'], Jenkins::Plugin['matrix-auth'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['pam-auth'], Jenkins::Plugin['windows-slaves'] ]
  }

  ::jenkins::plugin { 'timestamper':
    version => '1.8.8',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'token-macro':
    version => '2.2',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['workflow-aggregator'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'translation':
    version => '1.15',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'warnings':
    version => '4.63',
    require => [ Jenkins::Plugin['analysis-core'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['dashboard-view'], Jenkins::Plugin['matrix-project'], Jenkins::Plugin['maven-plugin'], Jenkins::Plugin['token-macro'] ]
  }

  ::jenkins::plugin { 'windows-slaves':
    version => '1.3.1',
    require => [ Jenkins::Plugin['bouncycastle-api'] ]
  }

  ::jenkins::plugin { 'workflow-aggregator':
    version => '2.5',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['pipeline-build-step'], Jenkins::Plugin['pipeline-input-step'], Jenkins::Plugin['pipeline-milestone-step'], Jenkins::Plugin['pipeline-model-definition'], Jenkins::Plugin['pipeline-stage-step'], Jenkins::Plugin['pipeline-stage-view'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-basic-steps'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-cps-global-lib'], Jenkins::Plugin['workflow-durable-task-step'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-multibranch'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-api':
    version => '2.20',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'workflow-basic-steps':
    version => '2.6',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['mailer'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'workflow-cps':
    version => '2.39',
    require => [ Jenkins::Plugin['ace-editor'], Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['jquery-detached'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-cps-global-lib':
    version => '2.8',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['git-client'], Jenkins::Plugin['git-server'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-scm-step'] ]
  }

  ::jenkins::plugin { 'workflow-durable-task-step':
    version => '2.14',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['durable-task'], Jenkins::Plugin['script-security'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-job':
    version => '2.12.2',
    require => [ Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-multibranch':
    version => '2.16',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['branch-api'], Jenkins::Plugin['cloudbees-folder'], Jenkins::Plugin['scm-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['structs'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-cps'], Jenkins::Plugin['workflow-job'], Jenkins::Plugin['workflow-scm-step'], Jenkins::Plugin['workflow-step-api'], Jenkins::Plugin['workflow-support'] ]
  }

  ::jenkins::plugin { 'workflow-scm-step':
    version => '2.6',
    require => [ Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'workflow-step-api':
    version => '2.12',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['structs'] ]
  }

  ::jenkins::plugin { 'workflow-support':
    version => '2.14',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['script-security'], Jenkins::Plugin['workflow-api'], Jenkins::Plugin['workflow-step-api'] ]
  }

  ::jenkins::plugin { 'xunit':
    version => '1.102',
    require => [ Jenkins::Plugin['bouncycastle-api'], Jenkins::Plugin['junit'] ]
  }

}
