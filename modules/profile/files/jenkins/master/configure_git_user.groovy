/* Configure Git User */

/* This script is designed to be run via jenkins-cli.jar in order to update the
 * configuration for the Jenkins GitSCM plugin.
 */
import jenkins.model.Jenkins

def gitscm_config = jenkins.model.Jenkins.getInstance().getDescriptor("hudson.plugins.git.GitSCM")
gitscm_config.setCreateAccountBasedOnEmail(false)
gitscm_config.setGlobalConfigName("jenkins")
gitscm_config.setGlobalConfigEmail("jenkins@build.ros.org")
gitscm_config.save()
