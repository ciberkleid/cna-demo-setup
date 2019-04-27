STUBS="${1}"
STUB_DEFAULT="io.pivotal:fortune-service:1.0.0"
PROJECT_NAME="greeting-ui"
M2_SETTINGS_REPO_USERNAME="ciberkleid"
#M2_SETTINGS_REPO_PASSWORD=""
M2_SETTINGS_REPO_ROOT="maven-repo"
REPO_WITH_BINARIES=https://${M2_SETTINGS_REPO_USERNAME}:${M2_SETTINGS_REPO_PASSWORD}@dl.bintray.com/${M2_SETTINGS_REPO_USERNAME}/${M2_SETTINGS_REPO_ROOT}
BUILD_OPTIONS=-Dstubrunner.snapshot-check-skip=true
export STUBS
export REPO_WITH_BINARIES

pushd ~/workspace/spinnaker-cloud-pipelines-home/${PROJECT_NAME}

# Check against provided stubs
echo -e "\n\n########## Test stubs ##########"
# Need to test one at a time for now due to a port binding error
savedStubs=${STUBS}
IFS=","
stubrunnerIDsArray=($STUBS)
length=${#stubrunnerIDsArray[@]}

# The build uses a stub, so if the array contains only one stub, skip to build
if [[ "$length" -eq 0 ]]; then
	echo -e "\nNo stub provided."
	echo "Build will test in offline mode with default stub: [${STUB_DEFAULT}]"
	STUBS=${STUB_DEFAULT}
	REPO_WITH_BINARIES=""
    BUILD_OPTIONS="${BUILD_OPTIONS} -Dstubrunner.stubs-mode=LOCAL"
	echo "Comment out the stubs-mode setting in your code. Continue? [y/n]:"
	read continue
	if [[ ${continue} != "y" ]]; then
		echo "\nAborting based on user input"
		exit 1
	fi
elif [[ "$length" -eq 1 ]]; then
	echo "Exactly one stub provided. Skipping to build (build will test against this stub)."
else
    echo -e "\nFirst stub (stubs[0]) will be tested during the build."
    echo -e "Starting tests with second stub (stubs[1]).\n"
fi
# Start with index=1 (index=0 will be tested during the build)
for ((i=1; i<${#stubrunnerIDsArray[@]}; ++i)); do
	STUBS="${stubrunnerIDsArray[$i]}"
    echo -e "\n\n##### Testing with stubs[$i]: ${STUBS}\n";
    #runDefaultTests
    ./mvnw clean test -Pdefault ${BUILD_OPTIONS}
done
unset IFS

echo -e "\n\n########## Build and upload ##########"
if [[ "$length" -ne 0 ]]; then
	STUBS="${stubrunnerIDsArray[0]}"
	echo -e "\nBuild will test with stubs[0]: ${STUBS}";
fi

#build
./mvnw clean install ${BUILD_OPTIONS}

popd
