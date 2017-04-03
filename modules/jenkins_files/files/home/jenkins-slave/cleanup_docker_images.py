#!/usr/bin/env python3
# Script to clean up docker images
import argparse
import dateutil.parser
import datetime
import docker
import fcntl
import logging
import psutil
import sys
import json
import traceback

from contextlib import contextmanager
from requests.exceptions import Timeout

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
    return usage.free * 100.0 / usage.total


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


def run_image_cleanup(args, minimum_age, dclient):
    logging.info("cleaning up docker images")
    images = dclient.images()

    #keep track of already tried images to avoid duplication
    processed_images = set()
    for i in reversed(images):
        dockerid = i['Id']
        repo_tags = i['RepoTags'][0] if '<none>:<none>' not in i['RepoTags'] else dockerid
        if dockerid in processed_images:
            logging.info("already processed %s, continuing" % repo_tags)
            continue
        if check_done(args):
            logging.info("Disk space satisfied ending")
            break
        processed_images.add(dockerid)
        try:
            info = dclient.inspect_image(dockerid)
            if docker_id_older(info, minimum_age):
                logging.info("removing image %s by identifier %s" % (dockerid, repo_tags))
                if args.dry_run:
                    logging.info("Dry run >> I would have removed image: %s" % repo_tags)
                else:
                    dclient.remove_image(repo_tags)
                    logging.info("successfully removed image: %s" % repo_tags)
            else:
                logging.info("skipped removal of image due to age: %s -- %s" % (info['Created'], repo_tags))
        except docker.errors.APIError as ex:
            logging.info("APIError: failed to remove image %s Exception [%s]" % (repo_tags, ex))
        except Timeout as ex:
            logging.info("Timeout: failed to remove image %s Exception [%s]" % (repo_tags, ex))



        print_progress(args)


def docker_id_older(docker_info, minimum_age):
    """ Check the age of a docker container or image is older
    """
    created = dateutil.parser.parse(docker_info['Created'])
    now = datetime.datetime.now(datetime.timezone.utc)
    return now - created > minimum_age


def main():
    parser = argparse.ArgumentParser(description='Free up disk space from docker images')
    parser.add_argument('--minimum-free-space', type=int, default=50,
                        help='Number of GB miniumum free required')
    parser.add_argument('--minimum-free-percent', type=int, default=50,
                        help='Number of percent free required')
    parser.add_argument('--path', type=str, default='/',
                        help='What mount point to introspect')
    parser.add_argument('--logfile', type=str,
                        default='/var/log/jenkins-slave/cleanup_docker_images.log',
                        help='Where to log output')
    parser.add_argument('--min-days', type=int, default=0,
                        help='The minimum age of items to clean up in days.')
    parser.add_argument('--min-hours', type=int, default=10,
                        help='The minimum age of items to clean up in hours, added to days.')
    parser.add_argument('--docker-api-version', type=str, default='1.16',
                            help='The docker server API level.')
    parser.add_argument('--dry-run', '-n', default=False,
                        action='store_true',
                        help='Do not actually clean up, just print to log.')

    args = parser.parse_args()
    dclient = docker.Client(base_url='unix://var/run/docker.sock', version=args.docker_api_version)
    minimum_age = datetime.timedelta(days=args.min_days, hours=args.min_hours)

    #initialize logging
    logging.basicConfig(filename=args.logfile, format='%(asctime)s %(message)s',
                        level=logging.INFO)
    logging.info(">>>>>> Starting run of cleanup_docker_images.py arguments %s" % args)
    if check_done(args):
        logging.info("Disk space satisfied before running, no need to run.")
        return
    print_progress(args)

    filename = '/tmp/cleanup_docker_images.py.marker'
    with open(filename, 'w') as fh:
        try:
            with flocked(fh):
                run_image_cleanup(args, minimum_age, dclient)
        except BlockingIOError as ex:
            logging.error("Failed to get lock on %s aborting. Exception[%s]. "
                          "This most likely means an instance of this script"
                          " is already running." %
                          (filename, ex))
            sys.exit(1)


if __name__ == '__main__':
    try:
        main()
        logging.info("<<<<<<< Finishing run of cleanup_docker_images.pyc cleanly")

    except:
        logging.error("Uncaught exception in cleanup_docker_image.py: %s" % traceback.format_exc())
