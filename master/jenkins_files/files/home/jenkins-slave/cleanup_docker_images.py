#!/usr/bin/env python3
# Script to clean up docker images
import argparse
import dateutil.parser
import datetime
import fcntl
import logging
import psutil
import subprocess
import sys
import json

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
    return reversed(images)


def remove_docker_image(imageid):
    cmd = ("docker rmi %s" % imageid).split()
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)


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


def run_image_cleanup(args, minimum_age):
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
            if docker_id_older(i, minimum_age):
                logging.info("removing image %s" % i)
                if args.dry_run:
                    logging.info("Dry run >> I would have removed image: %s" % i)
                else:
                    remove_docker_image(i)
                    logging.info("successfully removed image: %s" % i)
            else:
                logging.info("skipped removal of image due to age: %s" % i)
        except subprocess.CalledProcessError as ex:
            logging.info("failed to remove image %s Exception [%s] Output: [%s]" % (i, ex, ex.output))

        print_progress(args)


def inspect_docker_id(docker_id):
    cmd = ("docker inspect %s" % docker_id).split()
    info = subprocess.check_output(cmd).decode('utf8')
    return json.loads(info)[0]


def docker_id_older(docker_id, minimum_age):
    """ Check the age of a docker container or image is older
    """
    info = inspect_docker_id(docker_id)
    created = dateutil.parser.parse(info['Created'])
    now = datetime.datetime.now(datetime.timezone.utc)
    return now - created > minimum_age


def get_container_list():
    cmd = "docker ps -aq".split()
    containers = subprocess.check_output(cmd).decode('utf8').splitlines()
    return containers


def remove_docker_container(containerid):
    cmd = ("docker rm %s" % containerid).split()
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)


def run_container_cleanup(args, minimum_age):
    logging.info("cleaning up docker containers")
    containers = get_container_list()
    for c in containers:
        try:
            if docker_id_older(c, minimum_age):
                logging.info("removing container %s" % c)
                if args.dry_run:
                    logging.info("Dry run >> I would have removed container: %s" % c)
                else:
                    remove_docker_container(c)
                    logging.info("successfully removed container: %s" % c)
            else:
                logging.info("skipped removal of container due to age: %s" % c)
        except subprocess.CalledProcessError as ex:
            logging.info("failed to remove cointainer %s Exception [%s] Output [%s]" %
                         (c, ex, ex.output))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Free up disk space from docker images and containers')
    parser.add_argument('--minimum-free-space', type=int, default=50,
                        help='Number of GB miniumum free required')
    parser.add_argument('--minimum-free-percent', type=int, default=50,
                        help='Number of percent free required')
    parser.add_argument('--path', type=str, default='/',
                        help='What mount point to introspect')
    parser.add_argument('--logfile', type=str,
                        default='/var/log/jenkins-slave/cleanup_docker_images.log',
                        help='Where to log output')
    parser.add_argument('--min-days', type=int, default=1,
                        help='The minimum age of items to clean up in days.')
    parser.add_argument('--min-hours', type=int, default=0,
                        help='The minimum age of items to clean up in hours, added to days.')
    parser.add_argument('--dry-run', '-n', default=False,
                        action='store_true',
                        help='Do not actually clean up, just print to log.')

    args = parser.parse_args()

    minimum_age = datetime.timedelta(days=args.min_days, hours=args.min_hours)

    #initialize logging
    logging.basicConfig(filename=args.logfile, format='%(asctime)s %(message)s',
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
                run_container_cleanup(args, minimum_age)
                run_image_cleanup(args, minimum_age)
        except BlockingIOError as ex:
            logging.error("Failed to get lock on %s aborting. Exception[%s]. "
                          "This most likely means an instance of this script"
                          " is already running." %
                          (filename, ex))
            sys.exit(1)
