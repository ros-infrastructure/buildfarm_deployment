#!/bin/bash

case "$1" in
	main)
		repo=main
		key=ros-push_id
		;;
	testing)
		repo=testing
		key=ros-shadow-fixed-push_id
		;;
	*)
		echo "There is no upload configuration for '$1'."
		exit 1
esac

mkdir -p /var/repos/ubuntu/$repo/project/trace/
date -u > /var/repos/ubuntu/$repo/project/trace/repositories.ros.org
ssh -T -i $HOME/upload_triggers/$key ftpsync@ftp-osl.osuosl.org
exit_code=$?
if [ $exit_code -eq 0 ]
then
    echo "exit code 0"
    date
    exit 0
fi
echo "unknown exit code $exit_code"
date
exit 1
