#!/usr/bin/env python3
"""Fetch and format currently installed Jenkins plugins as puppet configuration.
"""

import json
import sys

from argparse import ArgumentParser
from base64 import b64encode
from collections import deque
from datetime import datetime
from urllib.request import Request, urlopen

resource_template = """  ::jenkins::plugin {{ '{name}':
    version => '{version}',
    require => {dependency_list}
  }}
"""

# Some plugins are managed by the upstream Jenkins puppet modules and should not be declared in this file.
# The skipped plugins can still be depended upon as they should be installed.
skip_plugins = ["credentials", "swarm"]

def main():
    parser = ArgumentParser(description="Generate a puppet class for currently installed Jenkins plugins.")
    parser.add_argument("--username")
    parser.add_argument("--password")
    parser.add_argument("--jenkins")
    args = parser.parse_args(sys.argv[1:])
    data = fetch_data(args)
    generate_class(data['plugins'])

def fetch_data(args):
    ciurl = "http://{}/pluginManager/api/json?depth=5".format(args.jenkins)
    plugin_request = Request(ciurl)
    plugin_request.add_header("Authorization", authorization_header_for(args.username, args.password))
    response = urlopen(plugin_request)
    data = json.loads(response.read().decode())
    return data

def generate_class(plugins):
    print("# This module was automatically generated on {0:%Y-%m-%d %H:%M:%S}".format(datetime.now()))
    print("# Instead of editing it, update plugins via the Jenkins web UI and rerun the generator.")
    print("# Otherwise your changes will be overwritten the next time it is run.")
    print("class profile::jenkins::rosplugins {")
    for plugin in sorted(plugins, key=lambda p: p['shortName']):
        if plugin['shortName'] in skip_plugins:
            continue
        dependencies = ", ".join(["Jenkins::Plugin['{}']".format(dep['shortName'])
                                  for dep in sorted(plugin['dependencies'], key=lambda d: d['shortName'])])
        print(resource_template.format(name=plugin['shortName'], version=plugin['version'],
                                       dependency_list="[ " + dependencies + " ]"))
    print("}")

def generate_plugin_url_list(plugins):
    """
    Print out a CLI script for updating these plugins with the jenkins CLI.
    I'm not fully in love with this yet so a small code change is required to use it.
    """

    plugin_dict = dict((p['shortName'], p) for p in plugins)
    # Make a tiny depth-first processing queue to add layered dependencies
    processed = set()
    queue = deque(p['shortName'] for p in plugins)
    while queue:
        plugin_name = queue.pop()
        if plugin_name in processed:
            continue
        plugin = plugin_dict[plugin_name]
        needs_deps = False
        for dep in plugin['dependencies']:
            if dep['shortName'] not in processed:
                needs_deps = True
                break
        if needs_deps:
            queue.appendleft(plugin_name)
            continue
        url = "https://updates.jenkins.io/download/plugins/{plugin}/{version}/{plugin}.hpi".format(
                plugin=plugin_name, version=plugin['version'])
        processed.add(plugin_name)
        print(url)


def authorization_header_for(username, password):
    encoded = b64encode((username + ":" + password).encode('ascii'))
    return "Basic {}".format(encoded.decode('ascii'))


if __name__ == '__main__':
    main()
