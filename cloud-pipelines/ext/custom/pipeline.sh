#!/bin/bash

set -o errexit
set -o errtrace
set -o pipefail

# synopsis {{{
# Contains customized common pipeline functions
# }}}

NUM_SOURCED_EXT_FILES=$((NUM_SOURCED_EXT_FILES + 1))

# FUNCTION: generateVersion {{{
# Generates version
# Returns version number.
function generateVersion() {
    local version="${PASSED_PIPELINE_VERSION:-${PIPELINE_VERSION:-}}"
	if [[ ! -z "${version}" ]]; then
		echo "${version}"
	else
		local version="$(extractMavenProperty "project.version")"
		local commitTime="$(${GIT_BIN} show --no-patch --no-notes --pretty='%ct')"
		commitTime="$(date -d @${commitTime} +'%Y%m%d.%H%M%SZ')"
		local commitIdShort="$(${GIT_BIN} rev-parse --short HEAD)"
		#local version="${version}+${commitTime}.${commitIdShort}"
		local version="${version}-${commitTime}.${commitIdShort}"
		echo "${version}"
	fi
} # }}}

# FUNCTION: findLatestProdTags {{{
# Echoes the latest N prod tags from git with trimmed refs part. Uses the
# LATEST_PROD_TAGS and PASSED_LATEST_PROD_TAGS env vars if latest production tags
# were already found. If not, retrieves the latest prod tags via [latestProdTagsFromGit]
# function and sets the [PASSED_LATEST_PROD_TAGS] and [LATEST_PROD_TAGS] env vars with
# the trimmed prod tags. Trimming occurs via the [trimRefsTag] function
function findLatestProdTags() {
	local prodTags="${PASSED_LATEST_PROD_TAGS:-${LATEST_PROD_TAGS:-}}"
	if [[ ! -z "${prodTags}" ]]; then
		echo "${prodTags}"
	else
		local latestProdTags
		latestProdTags="$(latestProdTagsFromGit)"
		i=0
		for tag in ${latestProdTags[@]}
		do
		  latestProdTags[$i]="$(trimRefsTag "${tag}")"
		  i=$((i + 1))
		done
		export LATEST_PROD_TAGS PASSED_LATEST_PROD_TAGS
		LATEST_PROD_TAGS="${latestProdTags[@]}"
		PASSED_LATEST_PROD_TAGS="${LATEST_PROD_TAGS[@]}"
		echo "${LATEST_PROD_TAGS[@]}"
	fi
} # }}}

# FUNCTION: latestProdTagsFromGit {{{
# Echos latest N production tags from git
# Uses [BACK_COMPATIBILITY_DEPTH, PROJECT_NAME] to determine number of tags to retrieve
function latestProdTagsFromGit() {
	if [[ -z "${PROJECT_NAME}" ]]; then
		export PROJECT_NAME="$(extractMavenProperty "project.artifactId")"
	fi
	local latestProdTags=$("${GIT_BIN}" for-each-ref --sort=-taggerdate --format '%(refname)' "refs/tags/prod/${PROJECT_NAME}" | head -${BACK_COMPATIBILITY_DEPTH})
    echo "${latestProdTags[@]}"
} # }}}

export -f generateVersion
export -f findLatestProdTags
export -f latestProdTagsFromGit
