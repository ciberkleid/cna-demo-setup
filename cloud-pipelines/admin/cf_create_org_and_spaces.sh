cf target
echo ""
echo "Will create org and spaces for pipelines setup"
echo "Continue? [y/n]"
read continue
if [[ $continue == "y" ]]; then
	cf create-org cloud-pipelines-org
	cf target -o cloud-pipelines-org
	cf create-space prod
	cf create-space stage
	cf create-space test-fortune-service
	cf create-space test-greeting-ui
else
	echo "aborting..."
fi
