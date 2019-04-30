#!/usr/bin/env bash

##### PRE-REQS ####################
# To run this demo, execute the following commands:
#   mkdir cna-demo
#   cd cna-demo
#   git clone https://github.com/ciberkleid/cna-demo-setup.git
#   source cna-demo-setup/cloud-pipelines/admin/_demo_wip.sh
###################################

# Set up env
CNA_DEMO_HOME=`pwd`
CNA_DEMO_TEMP="${CNA_DEMO_HOME}/_demo_tmp"
CNA_DEMO_SCRIPTS="${CNA_DEMO_HOME}/cna-demo-setup/cloud-pipelines/admin"

FORTUNE_SERVICE_BASELINE=9d944fa4e5d264e95446702ebb2c22c0ba13ce52
FORTUNE_SERVICE_BREAKING_API_CHANGE=3f999a6f502458abc96491441dadceeb9ea92e9e
FORTUNE_SERVICE_COMPATIBLE_API_CHANGE=9cc2b7470abb7bd1f6779278ea49fb5c97703eb6
FORTUNE_SERVICE_BREAKING_DB_CHANGE=eb885ffbf81369f46ea726476314eeb803c72749
FORTUNE_SERVICE_RELEASE=a654189fd5e53f14adbe86193dbee393b1f846fd

GREETING_UI_BASELINE=bcd72b4df684817499d2238ca0a3085f16d685ee
GREETING_UI_RELEASE=

echo -e "\n########## Set up environment"
mkdir -p "${CNA_DEMO_TEMP}"
cd "${CNA_DEMO_TEMP}"
export FORTUNE_SERVICE_HOME="${CNA_DEMO_TEMP}/fortune-service"
export GREETING_UI_HOME="${CNA_DEMO_TEMP}/greeting-ui"
if [[ ! -d "${FORTUNE_SERVICE_HOME}" ]]; then
    echo -e "\nCloning fortune-service:\n"
    git clone https://github.com/ciberkleid/fortune-service.git --quiet
else
    echo -e "Cleaning & re-setting existing clone of fortune-service"
    cd ${FORTUNE_SERVICE_HOME}
    git checkout master
    git clean -f -d
    git reset --hard HEAD
    git pull origin master
    git pull --rebase
    cd ..
fi
if [[ ! -d "${GREETING_UI_HOME}" ]]; then
    echo -e "\nCloning greeting-ui:\n"
    git clone https://github.com/ciberkleid/greeting-ui.git --quiet
else
    echo -e "Cleaning & re-setting existing clone of greeting-ui"
    cd ${GREETING_UI_HOME}
    git checkout master
    git clean -f -d
    git reset --hard HEAD
    git pull origin master
    git pull --rebase
    cd ..
fi

# Test fortune-service (baseline)
echo -e "\n\n########## Test fortune-service (baseline)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${FORTUNE_SERVICE_HOME}
            git checkout ${FORTUNE_SERVICE_BASELINE} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nSetting version to \"demo-baseline\" for install to local M2 repository"
            ./mvnw versions:set -DnewVersion="demo-baseline" -DprocessAllModules --quiet # ${BUILD_OPTIONS}
            echo -e "\nTest and build fortune-service (baseline). Initial release - no back compatibility checks."
            source ${CNA_DEMO_SCRIPTS}/local_fortune_service_build.sh
            mv pom.xml.versionsBackup pom.xml
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing fortune-service (baseline)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac
# Go back home between steps
cd "${CNA_DEMO_HOME}"

# Test fortune-service wip (broken API)
echo -e "\n\n########## Test fortune-service wip (broken API)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${FORTUNE_SERVICE_HOME}
            git checkout ${FORTUNE_SERVICE_BREAKING_CHANGES} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nSetting version to \"demo-snapshot\" for install to local M2 repository"
            ./mvnw versions:set -DnewVersion="demo-snapshot" -DprocessAllModules --quiet # ${BUILD_OPTIONS}
            echo -e "\nTest and build fortune-service wip (broken API). Checking back compatibility with V1 (demo-baseline)."
            # fortune-service-demo-baseline-stubs.jar should be in local M2 repo after fortune-service baseline build above
            source ${CNA_DEMO_SCRIPTS}/local_fortune_service_build.sh "demo-baseline"
            mv pom.xml.versionsBackup pom.xml
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing fortune-service wip (broken API)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac
# Go back home between steps
cd "${CNA_DEMO_HOME}"

# Test fortune-service wip (broken Schema)
echo -e "\n\n########## Test fortune-service wip (broken Schema)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${FORTUNE_SERVICE_HOME}
            git checkout ${FORTUNE_SERVICE_RELEASE_SNAPSHOT_BREAKING_SCHEMA_CHANGE} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nSetting version to \"demo-snapshot\" for install to local M2 repository"
            ./mvnw versions:set -DnewVersion="demo-snapshot" -DprocessAllModules --quiet # ${BUILD_OPTIONS}
            echo -e "\nTest and build fortune-service wip (broken Schema). Checking back compatibility with V1 (demo-baseline)."
            # fortune-service-demo-baseline-stubs.jar should be in local M2 repo after fortune-service baseline build above
            source ${CNA_DEMO_SCRIPTS}/local_fortune_service_build.sh "demo-baseline"
            mv pom.xml.versionsBackup pom.xml
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing fortune-service wip (broken Schema)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac
# Go back home between steps
cd "${CNA_DEMO_HOME}"

# Test fortune-service V2 (back compatible)
echo -e "\n\n########## Test fortune-service V2 (back compatible)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${FORTUNE_SERVICE_HOME}
            git checkout ${FORTUNE_SERVICE_RELEASE} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nSetting version to \"demo-release\" for install to local M2 repository"
            ./mvnw versions:set -DnewVersion="demo-release" -DprocessAllModules --quiet # ${BUILD_OPTIONS}
            echo -e "\nTest and build fortune-service V2 (back compatible). Checking back compatibility with V1 (demo-baseline)."
            # fortune-service-demo-baseline-stubs.jar should be in local M2 repo after fortune-service baseline build above
            source ${CNA_DEMO_SCRIPTS}/local_fortune_service_build.sh "demo-baseline"
            mv pom.xml.versionsBackup pom.xml
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing fortune-service V2 (back compatible)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac
# Go back home between steps
cd "${CNA_DEMO_HOME}"

# Test greeting-ui (baseline)
echo -e "\n\n########## Test greeting-ui (baseline) against fortune-service (baseline)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${GREETING_UI_HOME}
            git checkout ${GREETING_UI_BASELINE} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nTest and build greeting-ui (baseline). Checking back compatibility with V1 (demo-baseline)."
            # fortune-service-demo-baseline-stubs.jar should be in local M2 repo after fortune-service baseline build above
            source ${CNA_DEMO_SCRIPTS}/local_greeting_ui_build.sh "io.pivotal:fortune-service:demo-baseline" "-Dstubrunner.stubs-mode=LOCAL"
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing greeting-ui (baseline)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac

# Test greeting-ui V1 (baseline against fortune-ui V1 AND V2 back-compatible API change)
# Need to install fortuen V2 compatible api change as demo-release-alpha
echo -e "\n\n########## Test greeting-ui V2 (cross-compatible) against fortune-service (baseline) and fortune-service V2_ALPHA (back-compatible API change)"
echo -e "\nContinue or skip? [yS]: "
read continue
case ${continue} in
    y|Y)    echo "Continuing..."
            cd ${GREETING_UI_HOME}
            git checkout ${GREETING_UI_RELEASE} || { echo >&2 "git checkout failed with $?"; return 1; }
            echo -e "\nTest and build greeting-ui V2 (cross-compatible). Checking compatibility with fortune-service V2 (demo-release-alpha)."
            # fortune-service-demo-release-alpha-stubs.jar should be in local M2 repo after fortune-service V2 alpha build above  ################################
            source ${CNA_DEMO_SCRIPTS}/local_greeting_ui_build.sh "io.pivotal:fortune-service:demo-release-alpha" "-Dstubrunner.stubs-mode=LOCAL"
            echo -e "\nTest and build greeting-ui (baseline). Checking compatibility with fortune-service V1 (demo-baseline)."
            # fortune-service-demo-baseline-stubs.jar should be in local M2 repo after fortune-service baseline build above
            source ${CNA_DEMO_SCRIPTS}/local_greeting_ui_build.sh "io.pivotal:fortune-service:demo-baseline" "-Dstubrunner.stubs-mode=LOCAL"
            mv pom.xml.versionsBackup pom.xml
            cd "${CNA_DEMO_HOME}"
            echo -e "\nFinished testing greeting-ui (baseline)" ;;
    *)      echo -e "\nSkipping this test based on user input [$continue]."
            exit ;;
esac

# Go back home
cd "${CNA_DEMO_HOME}"