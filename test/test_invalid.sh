#!/usr/bin/env bash
source ./test/osht.sh

PLAN 14

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
OGREP '^::debug::Sending API request to Codecov API$'
OGREP '^::debug::Mapping response to an array of lines$'
OGREP '^::debug::Extracting response code from response$'
OGREP '^::debug::Logging response body$'
OGREP '^::group::Codecov API response$'
OGREP '^Error at \['\''coverage'\'', '\''status'\'', '\''project'\'', '\''default'\''\]:$'
OGREP '^must be of \['\''dict'\'', '\''boolean'\''\] type$'
OGREP '^::endgroup::$'
OGREP '^::debug::Evaluating result$'
OGREP '^Codecov configuration is invalid (got 400).$'
OGREP "^Update the Codecov configuration file at ${FILE} to make it valid.$"
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
