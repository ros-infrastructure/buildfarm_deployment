#!/usr/bin/env python3
# Script to clean up docker images
import argparse
import fcntl
import logging
import psutil
import subprocess
import sys

from contextlib import contextmanager


@contextmanager
def flocked(fd):
    """ Locks FD before entering the context, always releasing the lock.
    Raise BlockingIOError if already locked. """
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield
    finally:
        fcntl.flock(fd, fcntl.LOCK_UN)


def get_free_disk_space(path='/'):
    """Return the number of GB free."""
    usage = psutil.disk_usage(path)
    return usage.free / 1024.0 / 1024.0 / 1024.0


def get_free_disk_percentage(path='/'):
    """Return the number of percent free."""
    usage = psutil.disk_usage(path)
    return 100 - usage.percent


def get_image_list():
    cmd = "docker images -q".split()
    images = subprocess.check_output(cmd).decode('utf8').splitlines()
    cmd = "docker images -q --filter dangling=true".split()
    dangling_images = subprocess.check_output(cmd).decode('utf8').splitlines()
    images.extend(dangling_images)
    return reversed(images)

def remove_docker_image(imageid):
    cmd = ("docker rmi %s" % imageid).split()
    subprocess.check_call(cmd)


def check_done(args):
    if get_free_disk_percentage(args.path) >= args.minimum_free_percent and\
       get_free_disk_space(args.path) >= args.minimum_free_space:
        return True
    return False


def print_progress(args):
    logging.info("Free space %.2fGb of %s required" %
                 (get_free_disk_space(args.path),
                  args.minimum_free_space))
    logging.info("Free space %.2f%% of %s required" %
                 (get_free_disk_percentage(args.path),
                  args.minimum_free_percent))


def run_cleanup(args):
    logging.info("cleaning up docker images")
    images = get_image_list()

    #keep track of already tried images to avoid duplication
    processed_images = set()
    for i in images:
        if i in processed_images:
            continue
        if check_done(args):
            logging.info("Disk space satified ending")
            break
        try:
            processed_images.add(i)
            logging.info("removing image %s" % i)
            remove_docker_image(i)
            logging.info("successfully removed image: %s" % i)
        except subprocess.CalledProcessError as ex:
            logging.info("failed to remove image %s Exception [%s]" % (i, ex))

        print_progress(args)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Free up disk space from docker images')
    parser.add_argument('--minimum-free-space', type=int, default=50,
                        help='Number of GB miniumum free required')
    parser.add_argument('--minimum-free-percent', type=int, default=50,
                        help='Number of percent free required')
    parser.add_argument('--path', type=str, default='/',
                        help='What mount point to introspect')
    parser.add_argument('--log', type=str, default='/var/log/jenkins-slave/cleanup_docker_images.log',
                        help='Where to log output')
    args = parser.parse_args()

    #initialize logging
    logging.basicConfig(filename=args.log, format='%(asctime)s %(message)s',
                        level=logging.INFO)
    logging.info("Starting run of cleanup_docker_images.py arguments %s" % args)
    if check_done(args):
        logging.info("Disk space satified ending")
        sys.exit(0)
    print_progress(args)

    filename = '/tmp/cleanup_docker_images.py.marker'
    with open(filename, 'w') as fh:
        try:
            with flocked(fh):
                run_cleanup(args)
        except BlockingIOError as ex:
            logging.error("Failed to get lock on %s aborting. Exception[%s]. "
                          "This most likely means an instance of this script"
                          " is already running." %
                  (filename, ex))
            sys.exit(1)
