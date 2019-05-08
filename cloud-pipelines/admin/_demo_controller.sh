#!/usr/bin/env bash

##### PRE-REQS ####################
# To run this demo, log into GitHub and fork the following two repos:
#   https://github.com/ciberkleid/fortune-service
#   https://github.com/ciberkleid/greeting-ui
# Then, on your local workstation, execute the following commands:
#   mkdir cna-demo
#   cd cna-demo
#   git clone https://github.com/<YOUR-ORG>/fortune-service.git
#   git clone https://github.com/<YOUR-ORG>/greeting-ui.git
#   git clone https://github.com/ciberkleid/cna-demo-setup.git
#   source cna-demo-setup/cloud-pipelines/admin/_demo_controller.sh
# The script will assume that:
#   demoHome=`pwd`
#   fortuneServiceHome=${demoHome}/fortune-service
#   greetingUIHome=${demoHome}/greeting-ui
#   To override these values, set CNA_DEMO_HOME, CNA_DEMO_FORTUNE_SERVICE, and/or CNA_DEMO_GREETING_UI
###################################

demoHome="${CNA_DEMO_HOME:-`pwd`}"
fortuneServiceHome="${CNA_DEMO_FORTUNE_SERVICE:-$demoHome/fortune-service}"
greetingUIHome="${CNA_DEMO_GREETING_UI:-$demoHome/greeting-ui}"

echo -e "\nDemo will use the following setup:"
echo "demoHome=${demoHome}"
echo "fortuneServiceHome=${fortuneServiceHome}"
echo "greetingUIHome=${greetingUIHome}"

echo -e "\n-----> ACTION REQUIRED: Press any key to confirm and continue"
echo "(To quit and override default paths, press Ctrl+C and set CNA_DEMO_HOME, CNA_DEMO_FORTUNE_SERVICE, and/or CNA_DEMO_GREETING_UI)"
read anyKey

source "${demoHome}"/cna-demo-setup/cloud-pipelines/admin/_demo_env.sh

function runDemo() {
    echo -e "\n########## DEMO CONTROLLER ##########"
    echo -e "Choose an option: "
    echo "1 - Set trigger to fortune-service - baseline"
    echo "2 - Set trigger to greeting-ui     - baseline"
    echo "3 - Set trigger to fortune-service - breaking API change"
    echo "4 - Set trigger to fortune-service - back-compatible API change"
    echo "5 - Set trigger to fortune-service - breaking DB schema change"
    echo "6 - Set trigger to fortune-service - back-compatible DB schema change (final)"
    echo "7 - Set trigger to greeting-ui     - breaking API change"
    echo "8 - Set trigger to greeting-ui     - back-compatible API change (final)"
    echo "q - Quit"
    read choice

    case ${choice} in
        1)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_1
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalFortuneService1
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        2)  checkoutRelease "${greetingUIHome}" $GREETING_UI_1
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalGreetingUI1
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        3)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_2
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalFortuneService2
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        4)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_3
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalFortuneService3
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        5)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_4
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalFortuneService4
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        6)  checkoutRelease "${fortuneServiceHome}" $FORTUNE_SERVICE_5
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalFortuneService5
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        7)  checkoutRelease "${greetingUIHome}" $GREETING_UI_2
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalGreetingUI2
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        7)  checkoutRelease "${greetingUIHome}" $GREETING_UI_3
            echo -e "-----> ACTION REQUIRED: Also test & build locally? [yN]: "
            read demoLocal
            case ${demoLocal} in
                y|Y) buildLocalGreetingUI3
                ;;
                *) echo "Skipping local test/build"
                ;;
            esac
            ;;
        *)  echo -e "\nStopping demo controller"
            return 1 ;;
    esac
}

export -f runDemo

while [[ 1 ]]; do
    runDemo
done