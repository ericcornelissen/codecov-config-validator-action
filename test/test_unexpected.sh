#!/bin/bash
# SPDX-License-Identifier: MPL-2.0
source ./test/osht.sh

PLAN 4

# --- SETUP ------------------------------------------------------------------ #
SERVER_NAME='mock-codecov-api-unexpected'
SERVER_PORT='8080'

export API_URL="localhost:${SERVER_PORT}"
export FILE='testdata/codecov.yml'
export GITHUB_OUTPUT='github_output'

rm -f "${GITHUB_OUTPUT}"

docker run --rm --detach \
	--name "${SERVER_NAME}" \
	--volume './testdata/nginx-unexpected.conf:/etc/nginx/nginx.conf:ro' \
	--publish "${SERVER_PORT}:80" \
	nginx >/dev/null
sleep 1s

# --- RUN -------------------------------------------------------------------- #
NRUNS ./bin/validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=201'
IS "$(cat "${OSHT_STDIO}")" == '::debug::Sending API request to Codecov API
::debug::Mapping response to an array of lines
::debug::Extracting response code from response
::debug::Logging response body
::group::Codecov API response
::endgroup::
::debug::Evaluating result
Codecov configuration validation state unknown (got 201).

If this persists open an issue at:
https://github.com/ericcornelissen/codecov-config-validator-action/issues/new'
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
