#!/usr/bin/env python3
# Script to clean up docker images
import argparse
import psutil
import subprocess
import sys


def get_free_disk_space(path='/'):
    """Return the number of GB free."""
    usage = psutil.disk_usage(path)
    return usage.free/1024.0/1024.0/1024.0


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
    print("Free space %.2fGb of %s required" % (get_free_disk_space(args.path),
                                                args.minimum_free_space))
    print("Free space %.2f%% of %s required" % (get_free_disk_percentage(args.path),
                                                args.minimum_free_percent))


parser = argparse.ArgumentParser(description='Free up disk space from docker images')
parser.add_argument('--minimum-free-space', type=int, default=50,
                    help='Number of GB miniumum free required')
parser.add_argument('--minimum-free-percent', type=int, default=50,
                    help='Number of percent free required')
parser.add_argument('--path', type=str, default='/',
                    help='What mount point to introspect')
args = parser.parse_args()
if check_done(args):
    print("Disk space satified ending")
    sys.exit(0)
print_progress(args)

images = get_image_list()

#keep track of already tried images to avoid duplication
processed_images = set()
for i in images:
    if i in processed_images:
        continue
    if check_done(args):
        print("Disk space satified ending")
        break
    try:
        processed_images.add(i)
        print("removing image %s" % i)
        remove_docker_image(i)
    except subprocess.CalledProcessError as ex:
        print("failed to remove image %s Exception [%s]" % (i, ex))

    print_progress(args)
