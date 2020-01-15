/* Enable TCP port for inbound agents */

/* This script is designed to be run via jenkins-cli.jar in order to enable
 * connection from agents.
 */

import jenkins.model.Jenkins

def instance=jenkins.model.Jenkins.instance
instance.setSlaveAgentPort(0)
instance.save()
