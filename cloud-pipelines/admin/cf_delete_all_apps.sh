#!/usr/bin/env bash
cf target -o cloud-pipelines-org
echo ""
echo "Will delete all apps in all spaces in this org!!"
echo "Continue? [y/n]"
read continue
if [[ $continue == "y" ]]; then
	cf do-all --org delete {} -f
else
	echo "aborting..."
fi
