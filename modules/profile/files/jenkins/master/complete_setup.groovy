/* Configure Git User */

/* This script is designed to be run via jenkins-cli.jar in order to update the
 * configuration for the Jenkins GitSCM plugin.
 */
import jenkins.model.Jenkins

jenkins.model.Jenkins.getInstance().getSetupWizard().completeSetup()
