#!/usr/bin/env python3
"""Fetch and format currently installed Jenkins plugins as puppet configuration.
"""

import json
import sys

from argparse import ArgumentParser
from base64 import b64encode
from datetime import datetime
from urllib.request import Request, urlopen

resource_template = """  ::jenkins::plugin {{ '{name}':
    version => '{version}',
    require => {dependency_list}
  }}
"""

def main():
    parser = ArgumentParser(description="Generate a puppet class for currently installed Jenkins plugins.")
    parser.add_argument("--username")
    parser.add_argument("--password")
    parser.add_argument("--jenkins")
    args = parser.parse_args(sys.argv[1:])
    generate_class(args)


def generate_class(args):
    print("# This module was automatically generated on {0:%Y-%m-%d %H:%M:%S}".format(datetime.now()))
    print("# Instead of editing it, update plugins via the Jenkins web UI and rerun the generator.")
    print("# Otherwise your changes will be overwritten the next time it is run.")
    print("class profile::jenkins::rosplugins {")
    ciurl = "http://{}/pluginManager/api/json?depth=5".format(args.jenkins)
    plugin_request = Request(ciurl)
    plugin_request.add_header("Authorization", authorization_header_for(args.username, args.password))
    response = urlopen(plugin_request)
    parsed = json.loads(response.read().decode())
    for plugin in sorted(parsed['plugins'], key=lambda p: p['shortName']):
        dependencies = ", ".join(["Jenkins::Plugin['{}']".format(dep['shortName'])
                                  for dep in sorted(plugin['dependencies'], key=lambda d: d['shortName'])])
        print(resource_template.format(name=plugin['shortName'], version=plugin['version'],
                                       dependency_list="[ " + dependencies + " ]"))
    print("}")


def authorization_header_for(username, password):
    encoded = b64encode((username + ":" + password).encode('ascii'))
    return "Basic {}".format(encoded.decode('ascii'))


if __name__ == '__main__':
    main()
