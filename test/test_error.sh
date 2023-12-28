#!/bin/bash
# SPDX-License-Identifier: MPL-2.0
source ./test/osht.sh

PLAN 4

# --- SETUP ------------------------------------------------------------------ #
SERVER_NAME='mock-codecov-api-error'
SERVER_PORT='8080'

export API_URL="localhost:${SERVER_PORT}"
export FILE='testdata/codecov.yml'
export GITHUB_OUTPUT='github_output'

rm -f "${GITHUB_OUTPUT}"

docker run --rm --detach \
	--name "${SERVER_NAME}" \
	--volume './testdata/nginx-error.conf:/etc/nginx/nginx.conf:ro' \
	--publish "${SERVER_PORT}:80" \
	nginx >/dev/null
sleep 1s

# --- RUN -------------------------------------------------------------------- #
NRUNS ./bin/validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=500'
IS "$(cat "${OSHT_STDIO}")" == '::debug::Sending API request to Codecov API
::debug::Mapping response to an array of lines
::debug::Extracting response code from response
::debug::Logging response body
::group::Codecov API response
{"error": "Server Error (500)"}
::endgroup::
::debug::Evaluating result
Codecov configuration could not be validated (got 500).

You can try to rerun this job after a short delay and it should pass then.
If the exact response code 500 persists, verify Codecov does not have an outage.'
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
