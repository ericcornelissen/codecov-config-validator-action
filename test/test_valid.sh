#!/bin/bash
# SPDX-License-Identifier: MPL-2.0
source ./test/osht.sh

PLAN 4

# --- SETUP ------------------------------------------------------------------ #
SERVER_NAME='mock-codecov-api-valid'
SERVER_PORT='8080'

export API_URL="localhost:${SERVER_PORT}"
export FILE='testdata/codecov.yml'
export GITHUB_OUTPUT='github_output'

rm -f "${GITHUB_OUTPUT}"

docker run --rm --detach \
	--name "${SERVER_NAME}" \
	--volume './testdata/nginx-valid.conf:/etc/nginx/nginx.conf:ro' \
	--publish "${SERVER_PORT}:80" \
	nginx >/dev/null
sleep 1s

# --- RUN -------------------------------------------------------------------- #
RUNS ./validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=200'
IS "$(cat "${OSHT_STDIO}")" == '::debug::Sending API request to Codecov API
::debug::Mapping response to an array of lines
::debug::Extracting response code from response
::debug::Logging response body
::group::Codecov API response
Valid!

{
  "coverage": { }
}
::endgroup::
::debug::Evaluating result
Codecov configuration is valid.'
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
