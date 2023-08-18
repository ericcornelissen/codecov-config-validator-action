#!/usr/bin/env bash
source ./test/osht.sh

PLAN 4

# --- SETUP ------------------------------------------------------------------ #
SERVER_NAME='mock-codecov-api-invalid'
SERVER_PORT='8080'

export API_URL="localhost:${SERVER_PORT}"
export FILE='testdata/codecov.yml'
export GITHUB_OUTPUT='github_output'

rm -f "${GITHUB_OUTPUT}"

docker run --rm --detach \
	--name "${SERVER_NAME}" \
	--volume './testdata/nginx-invalid.conf:/etc/nginx/nginx.conf:ro' \
	--publish "${SERVER_PORT}:80" \
	nginx >/dev/null
sleep 1s

# --- RUN -------------------------------------------------------------------- #
NRUNS ./validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=400'
IS "$(cat "${OSHT_STDIO}")" == '::debug::Sending API request to Codecov API
::debug::Mapping response to an array of lines
::debug::Extracting response code from response
::debug::Logging response body
::group::Codecov API response
Error at \['\''coverage'\'', '\''status'\'', '\''project'\'', '\''default'\'']:
must be of \['\''dict'\'', '\''boolean'\''] type
::endgroup::
::debug::Evaluating result
Codecov configuration is invalid (got 400).

Update the Codecov configuration file at '"${FILE}"' to make it valid.'
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
