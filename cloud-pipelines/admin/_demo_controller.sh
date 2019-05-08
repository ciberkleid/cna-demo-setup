#!/usr/bin/env bash

##### PRE-REQS ####################
# To run this demo, execute the following commands:
#   mkdir cna-demo
#   cd cna-demo
#   git clone https://github.com/ciberkleid/cna-demo-setup.git
#   source cna-demo-setup/cloud-pipelines/admin/_demo_controller.sh
###################################

defaultDemoHome=~/workspace/cna-demo

echo -e "Enter demo home directory [${defaultDemoHome}]: "
read demoHome
demoHome="${demoHome:-$defaultDemoHome}"

source "${demoHome}"/cna-demo-setup/cloud-pipelines/admin/_demo_env.sh

defaultFortuneServiceHome="${defaultDemoHome}"/fortune-service
defaultGreetingUIHome="${defaultDemoHome}"/greeting-ui

echo -e "Enter fortune-service home directory [${defaultFortuneServiceHome}]: "
read fortuneServiceHome
fortuneServiceHome="${fortuneServiceHome:-$defaultFortuneServiceHome}"

echo -e "Enter greeting-ui home directory [${defaultGreetingUIHome}]: "
read greetingUIHome
greetingUIHome="${greetingUIHome:-$defaultGreetingUIHome}"

function checkoutRelease() {
    echo -e "\nChecking out selected release"
    local sourceDir="${1}"
    local commitID="${2}"
    local savedPWD=`pwd`
    cd ${sourceDir}
    git checkout "${commitID}" --quiet
    if [[ `git branch | grep cloud-pipelines-spinnaker` == "" ]]; then
        git checkout -b cloud-pipelines-spinnaker --quiet
    else
        git checkout cloud-pipelines-spinnaker --quiet
    fi
    git push origin cloud-pipelines-spinnaker --quiet
    local repo=$(basename $sourceDir)
    local commitMessage=$(git log -n 1 --pretty=format:%s "${commitID}")
    cd ${savedPWD}
    echo -e "Trigger set: repo=[${repo}] branch=[cloud-pipelines-spinnaker] commit_id=[${commitID}] commit_msg=[${commitMessage}]"
    echo -e "-----> ACTION REQUIRED:"
    echo -e "Please trigger the build-and-upload job for ${repo}/cloud-pipelines-spinnaker on your CI server"
    echo -e "When ready, press any key to continue"
    read anyKey
}

export -f checkoutRelease

function runDemo() {
    echo -e "\n########## DEMO CONTROLLER ##########"
    echo -e "Choose an option: "
    echo "1 - Set trigger to fortune-service - baseline"
    echo "2 - Set trigger to greeting-ui     - baseline"
    echo "3 - Set trigger to fortune-service - breaking API change"
    echo "4 - Set trigger to fortune-service - back-compatible API change"
    echo "5 - Set trigger to fortune-service - breaking DB schema change"
    echo "6 - Set trigger to fortune-service - back-compatible DB schema change (final)"
    echo "7 - Set trigger to greeting-ui     - cross-compatible API change (final)"
    echo "8 - Exit"
    read choice

    case ${choice} in
        1)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_1 ;;
        2)  checkoutRelease "${greetingUIHome}" $GREETING_UI_1 ;;
        3)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_2 ;;
        4)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_3 ;;
        5)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_4 ;;
        6)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_5 ;;
        7)  checkoutRelease "${greetingUIHome}" $GREETING_UI_2 ;;
        *)  echo -e "\nExiting"
            exit ;;
    esac
}

export -f runDemo

while [[ 1 ]]; do
    runDemo
done