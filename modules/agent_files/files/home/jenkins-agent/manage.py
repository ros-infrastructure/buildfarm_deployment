#!/usr/bin/env python

# Copyright (c) 2014, Tully Foote

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


import os
import subprocess
import socket
import sys
import threading
import time

redirect_cmd = "iptables -t nat -A PREROUTING -p tcp" \
               " --dport 80 -j REDIRECT --to 3129 -w"
remove_redirect_cmd = redirect_cmd.replace(' -A ', ' -D ')
check_redirect_cmd = redirect_cmd.replace(' -A ', ' -C ')
LOCAL_PORT = 3128


def is_port_open(port_num):
    """ Detect if a port is open on localhost"""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    return sock.connect_ex(('127.0.0.1', port_num)) == 0


def is_forwarding_on():
    """
    Detect if the transparent proxy rule is already installed.
    """
    try:
        with open(os.devnull, "w") as fnull:
            subprocess.check_call(check_redirect_cmd.split(),
                stdout=fnull, stderr=fnull)
        return True
    except:
        return False


def enable():
    """
    Disable IP tables forwarding for a transparent proxy
    """
    print("Enabling IPtables forwarding: '%s'" % redirect_cmd)
    try:
        subprocess.check_call(redirect_cmd.split())
        return True
    except:
        print("Failed to setup IPTABLES. Did you use --privileged"
              " if not you need to run [[%s]]" % redirect_cmd)
    return False


def disable():
    """
    Disable IP tables forwarding for a transparent proxy
    """
    print("Disabling IPtables forwarding: '%s'" % remove_redirect_cmd)
    subprocess.check_call(remove_redirect_cmd.split())


class RedirectContext(threading.Thread):
    """ A context to make sure that the iptables rules are removed
    after they are inserted."""

    def __init__(self):
        super(RedirectContext, self ).__init__()
        self.setup = False
        self.running = True

    def __enter__(self):
        self.setup = is_forwarding_on() or enable()
        print("Starting thread to monitor proxy status")
        self.start()
        return self

    def __exit__(self, ex_type, ex_value, traceback):
        self.running = False
        print("waiting for monitoring thread to shutdown")
        self.join()
        if is_forwarding_on:
            disable()

    def run(self):
        while self.running:
            # start with sleep to allow continue
            time.sleep(1)
            if is_port_open(LOCAL_PORT):
                if is_forwarding_on():
                    continue
                else:
                    print("Port %s detected open setting up IPTables redirection" %
                          LOCAL_PORT)
                    enable()
            else:
                if is_forwarding_on():
                    print("port closed but forwarding on, disabling")
                    disable()
                else:
                    continue


def main():
    if os.geteuid() != 0:
        print("This must be run as root or with sudo, aborting")
        return -1

    with RedirectContext():
        # Wait a ctrl-c
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt as ex:
            # Catch Ctrl-C and pass it into the squid instance
            print("CTRL-C caught, shutting down.")
        except Exception as ex:
            print("Caught exception, %s, shutting down" % ex)

    return 0

if __name__ == '__main__':
    sys.exit(main())
