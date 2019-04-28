#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail

# synopsis {{{
# Contains customized Maven related build functions
# }}}

NUM_SOURCED_EXT_FILES=$((NUM_SOURCED_EXT_FILES + 1))

# FUNCTION: runDefaultTests {{{
# Will run the tests with [default] profile. Will not build or upload artifacts.
function runDefaultTests() {
	echo "Running default tests."

	if [[ "${CI}" == "CONCOURSE" ]]; then
		# shellcheck disable=SC2086
		"${MAVENW_BIN}" clean test -Pdefault -Drepo.with.binaries="${REPO_WITH_BINARIES}" ${BUILD_OPTIONS} || (printTestResults && return 1)
	else
		# shellcheck disable=SC2086
		"${MAVENW_BIN}" clean test -Pdefault -Drepo.with.binaries="${REPO_WITH_BINARIES}" ${BUILD_OPTIONS}
	fi
} # }}}

export -f runDefaultTests
