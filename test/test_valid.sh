#!/usr/bin/env bash
source ./test/osht.sh

PLAN 10

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

# --- RUN -------------------------------------------------------------------- #
RUNS ./validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=200'
OGREP '^::debug::Sending API request to Codecov API$'
OGREP '^::debug::Mapping response to an array of lines$'
OGREP '^::debug::Extracting response code from response$'
OGREP '^::debug::Logging response body$'
OGREP '^::group::Codecov API response$'
# TODO: response
OGREP '^::endgroup::$'
OGREP '^::debug::Evaluating result$'
OGREP '^Codecov configuration is valid.$'

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
