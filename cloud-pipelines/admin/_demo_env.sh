#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail

########## fortune-service commits ##########
# Baseline
export FORTUNE_SERVICE_1=9d944fa4e5d264e95446702ebb2c22c0ba13ce52
# Breaking API change
export FORTUNE_SERVICE_2=3f999a6f502458abc96491441dadceeb9ea92e9e
# Back-compatible API change
export FORTUNE_SERVICE_3=9cc2b7470abb7bd1f6779278ea49fb5c97703eb6
# Breaking DB schema change
export FORTUNE_SERVICE_4=eb885ffbf81369f46ea726476314eeb803c72749
# Back-compatible DB schema change
export FORTUNE_SERVICE_5=09dd72dd6bb7a4a117ea6cb93d6743e3cc4bd842

########## greeting-ui commits ##########
# Baseline
export GREETING_UI_1=bcd72b4df684817499d2238ca0a3085f16d685ee
# Breaking API change
export GREETING_UI_2=6b7333190aa44afaaaaa3f4d184d9f9016993701
# Back-compatible API change
export GREETING_UI_3=0638ccda30d9320b573d6ee0c63cb609b987a1c5


########## demo functions ##########
quietFlag="--quiet"
#quietFlag=""

function checkoutRelease() {
    echo -e "\nChecking out selected release"
    local sourceDir="${1}"
    local commitID="${2}"
    local savedPWD=`pwd`
    cd ${sourceDir}
    if [[ `git branch | grep cloud-pipelines-spinnaker` == "" ]]; then
        git checkout -b cloud-pipelines-spinnaker ${quietFlag} || { echo >&2 "git checkout new branch failed with $?"; return 1; }
    else
        git checkout cloud-pipelines-spinnaker ${quietFlag} || { echo >&2 "git checkout branch failed with $?"; return 1; }
    fi
    git reset --hard ${commitID} ${quietFlag} || { echo >&2 "git reset commit id failed with $?"; return 1; }
    git push -f --set-upstream origin cloud-pipelines-spinnaker ${quietFlag} || { echo >&2 "git push failed with $?"; return 1; }
    git log -1
    local repo=$(basename $sourceDir)
    local commitMessage=$(git log -n 1 --pretty=format:%s "${commitID}")
    cd ${savedPWD}
    echo -e "Trigger set: repo=[${repo}] branch=[cloud-pipelines-spinnaker] commit_id=[${commitID}] commit_msg=[${commitMessage}]"
    echo -e "-----> ACTION REQUIRED: Trigger build-and-upload job for ${repo}/cloud-pipelines-spinnaker on your CI server"
    echo -e "When ready, press any key to continue"
    read anyKey
}

buildLocalFortuneService1() {
    sourceDir="${fortuneServiceHome}"
    version=build-1
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\nBuilding ${repo}-${version}"
    echo -e "Baseline release - no API or DB back compatibility checks needed. Expecting success."
    rm -rf ~/.m2/repository/io/pivotal/${repo}/${version}
    ./mvnw clean install

    echo -e "\nFinished building ${repo}-${version}"
    echo "Generated files in local m2 repo:"
    ls ~/.m2/repository/io/pivotal/${repo}/${version} || { echo >&2 "ls failed with $?"; return 1; }
    cd ${savedPWD}
}

buildLocalFortuneService2() {
    sourceDir="${fortuneServiceHome}"
    version=build-2
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\Testing ${repo}-${version}"
    echo -e "Breaking API change. Testing without back-compatibility checks. Expecting success."
    ./mvnw clean test

    echo -e "\nCheck API back compatibility against fortune-service-build-1. Expecting failure due to known back compatibility issues."
    ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-1 -Dcontracts.mode=LOCAL  || { echo >&2 "API compatability test failed with $?"; return 0; }

    echo -e "\nFinished testing ${repo}-${version}"
    cd ${savedPWD}
}

buildLocalFortuneService3() {
    sourceDir="${fortuneServiceHome}"
    version=build-3
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\Testing ${repo}-${version}"
    echo -e "\nBack-compatible API change. Check API back compatibility against fortune-service-build-1. Expecting success."
    ./mvnw clean verify -Papicompatibility -Dlatest.production.version=build-1 -Dcontracts.mode=LOCAL

    echo -e "\nBuilding ${repo}-${version}. Expecting success."
    rm -rf ~/.m2/repository/io/pivotal/${repo}/${version}
    ./mvnw clean install
    echo -e "\nFinished building ${repo}-${version}"
    echo "Generated files in local m2 repo:"
    ls ~/.m2/repository/io/pivotal/${repo}/${version} || { echo >&2 "ls failed with $?"; return 1; }
    cd ${savedPWD}
}

buildLocalFortuneService4() {
    sourceDir="${fortuneServiceHome}"
    version=build-4
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\Testing ${repo}-${version}"
    echo -e "Breaking DB schema change. Testing without back-compatibility checks. Expecting success."
    ./mvnw clean test

    echo -e "\nCheck DB schema back compatibility against fortune-service-build-3. Expecting failure due to known back compatibility issues."
    rm -rf ./git/cna-demo-temp
    mkdir -p .git/cna-demo-temp
    git clone https://github.com/ciberkleid/fortune-service.git ./git/cna-demo-temp/fortune-service-blue
    cd ./git/cna-demo-temp/fortune-service-blue
    git checkout "${FORTUNE_SERVICE_3}" ${quietFlag} || { echo >&2 "git checkout commit failed with $?"; return 1; }
    ./mvnw clean test -Dspring.flyway.locations=filesystem:${fortuneServiceHome}/src/main/resources/db/migration  || { echo >&2 "DB compatability test failed with $?"; return 0; }
    cd ${fortuneServiceHome}
    echo -e "\nFinished testing ${repo}-${version}"
    cd ${savedPWD}
}

buildLocalFortuneService5() {
    sourceDir="${fortuneServiceHome}"
    version=build-5
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\Testing ${repo}-${version}"
    echo -e "Back compatible DB schema change. Check DB schema back compatibility against fortune-service-build-3. Expecting success."
    rm -rf ./git/cna-demo-temp
    mkdir -p .git/cna-demo-temp
    git clone https://github.com/ciberkleid/fortune-service.git ./git/cna-demo-temp/fortune-service-blue
    cd ./git/cna-demo-temp/fortune-service-blue
    git checkout "${FORTUNE_SERVICE_3}" ${quietFlag} || { echo >&2 "git checkout commit failed with $?"; return 1; }
    ./mvnw clean test -Dspring.flyway.locations=filesystem:${fortuneServiceHome}/src/main/resources/db/migration
    cd ${fortuneServiceHome}

    echo -e "\nBuilding ${repo}-${version}. Expecting success."
    rm -rf ~/.m2/repository/io/pivotal/${repo}/${version}
    ./mvnw clean install
    echo -e "\nFinished building ${repo}-${version}"
    echo "Generated files in local m2 repo:"
    ls ~/.m2/repository/io/pivotal/${repo}/${version} || { echo >&2 "ls failed with $?"; return 1; }
    cd ${savedPWD}
}

buildLocalGreetingUI1() {
    sourceDir="${greetingUIHome}"
    version=build-1
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\nBuilding ${repo}-${version}"
    echo -e "Baseline release. Checking against fortune-service-build-1 stub. Expecting success."
    export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL

    echo -e "\nFinished building ${repo}-${version}"
    cd ${savedPWD}
}

buildLocalGreetingUI2() {
    sourceDir="${greetingUIHome}"
    version=build-2
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\Testing ${repo}-${version}"
    echo -e "Breaking API change. Checking against fortune-service-build-3 stub. Expecting success."
    export STUBS=io.pivotal:fortune-service:build-3; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
    #export STUBS=io.pivotal:fortune-service:build-5; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL

    echo -e "Breaking API change. Checking against fortune-service-build-1 stub. Expecting failure."
    export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL || { echo >&2 "API compatability test failed with $?"; return 0; }

    echo -e "\nFinished testing ${repo}-${version}"
    cd ${savedPWD}
}

buildLocalGreetingUI3() {
    sourceDir="${greetingUIHome}"
    version=build-3
    repo=$(basename $sourceDir)
    savedPWD=`pwd`
    cd ${sourceDir}
    ./mvnw versions:set -DnewVersion="${version}" -DprocessAllModules ${quietFlag}

    echo -e "\nBuilding ${repo}-${version}"
    echo -e "Back-compatible API change. Checking against fortune-service-build-1 and fortune-service-build-3 stubs. Expecting success."
    export STUBS=io.pivotal:fortune-service:build-1; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
    export STUBS=io.pivotal:fortune-service:build-3; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL
    #export STUBS=io.pivotal:fortune-service:build-5; ./mvnw clean test -Dstubrunner.stubs-mode=LOCAL

    echo -e "\nFinished testing ${repo}-${version}"
    cd ${savedPWD}
}

export -f checkoutRelease
export -f buildLocalFortuneService1
export -f buildLocalFortuneService2
export -f buildLocalFortuneService3
export -f buildLocalFortuneService4
export -f buildLocalFortuneService5
export -f buildLocalGreetingUI1
export -f buildLocalGreetingUI2
export -f buildLocalGreetingUI3