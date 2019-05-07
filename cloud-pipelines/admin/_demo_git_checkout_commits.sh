#!/usr/bin/env bash

source cloud-pipelines/admin/_demo_env.sh

echo -e "Enter fortune-service home directory [/Users/ciberkleid/workspace/spinnaker-cloud-pipelines-home/fortune-service]: "
read fortuneHome
fortuneHome="${fortuneHome:-/Users/ciberkleid/workspace/spinnaker-cloud-pipelines-home/fortune-service}"

echo -e "Enter greeting-ui home directory [~/Users/ciberkleid/workspace/spinnaker-cloud-pipelines-home/greeting-ui]: "
read greetingHome
greetingHome="${greetingHome:-/Users/ciberkleid/workspace/spinnaker-cloud-pipelines-home/greeting-ui}"


function checkoutRelease() {
    local sourceDir="${1}"
    local commitID="${2}"
    cd ${sourceDir}
    git checkout "${commitID}"

    if [[ `git branch | grep cloud-pipelines-spinnaker` == "" ]]; then
        git checkout -b cloud-pipelines-spinnaker
    else
        git checkout cloud-pipelines-spinnaker
    fi
    git push origin cloud-pipelines-spinnaker
    echo -e "\n\n### Trigger ${sourceDir}-build-and-upload in CI tool."
    echo -e "\n\n### Then return here and continue script."
}

function continueOrSkip() {
    local comment="${1}"
    echo -e "\n${comment}"
    echo -e "\nContinue? [yN]: "
    read continue
    case ${continue} in
        y|Y)    echo "Continuing..." ;;
        *)      return ;;
    esac
}

export -f checkoutRelease
export -f continueOrSkip

continueOrSkip "Setting trigger to fortune-service - baseline"
checkoutRelease "${fortuneHome}" $FORTUNE_SERVICE_1

continueOrSkip "Setting trigger to greeting-ui - baseline"
checkoutRelease "${greetingHome}" $GREETING_UI_1

continueOrSkip "Setting trigger to fortune-service - breaking API change"
checkoutRelease "${fortuneHome}" $FORTUNE_SERVICE_2

continueOrSkip "Setting trigger to fortune-service - back-compatible API change"
checkoutRelease "${fortuneHome}" $FORTUNE_SERVICE_3

continueOrSkip "Setting trigger to fortune-service - breaking DB schema change"
checkoutRelease "${fortuneHome}" $FORTUNE_SERVICE_4

continueOrSkip "Setting trigger to fortune-service - back-compatible DB schema change (final)"
checkoutRelease "${fortuneHome}" $FORTUNE_SERVICE_5

continueOrSkip "Setting trigger to greeting-ui - cross-compatible API change (final)"
checkoutRelease "${greetingHome}" $GREETING_UI_2
echo "End of script"