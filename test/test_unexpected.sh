#!/usr/bin/env bash
source ./test/osht.sh

PLAN 13

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
NRUNS ./validate.sh

IS "$(cat "${GITHUB_OUTPUT}")" == 'status-code=201'
OGREP '^::debug::Sending API request to Codecov API$'
OGREP '^::debug::Mapping response to an array of lines$'
OGREP '^::debug::Extracting response code from response$'
OGREP '^::debug::Logging response body$'
OGREP '^::group::Codecov API response$'
# TODO: response
OGREP '^::endgroup::$'
OGREP '^::debug::Evaluating result$'
OGREP '^Codecov configuration validation state unknown (got 201).$'
OGREP '^If this persists open an issue at:$'
OGREP '^https://github.com/ericcornelissen/codecov-config-validator-action/issues/new$'
NEGREP .

# --- TEARDOWN --------------------------------------------------------------- #
docker stop "${SERVER_NAME}" >/dev/null
