#!/usr/bin/env bash
source ./test/osht.sh

PLAN 12

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
NRUNS ./validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=500'
OGREP '^::debug::Sending API request to Codecov API$'
OGREP '^::debug::Mapping response to an array of lines$'
OGREP '^::debug::Extracting response code from response$'
OGREP '^::debug::Logging response body$'
OGREP '^::group::Codecov API response$'
# TODO: response
OGREP '^::endgroup::$'
OGREP '^::debug::Evaluating result$'
OGREP '^Codecov configuration could not be validated (got 500).$'
OGREP '^You can try to rerun this job after a short delay and it should pass then.$'
OGREP '^If the exact response code 500 persists, verify Codecov does not have an outage.$'

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
