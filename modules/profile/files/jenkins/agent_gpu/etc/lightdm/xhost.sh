#!/bin/sh
xhost +si:localuser:jenkins-agent
touch /tmp/xhost_`date +"%T"`
