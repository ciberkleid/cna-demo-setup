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
export FORTUNE_SERVICE_5=a654189fd5e53f14adbe86193dbee393b1f846fd

########## greeting-ui commits ##########
# Baseline
export GREETING_UI_1=bcd72b4df684817499d2238ca0a3085f16d685ee
# Cross-compatible API change
export GREETING_UI_2=afcda628abab7c0a979d00d944e08f2b997b06be
