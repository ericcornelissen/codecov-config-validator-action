#!/bin/bash

debug() {
	echo "::debug::$1"
}

# ---------------------------------------------------------------------------- #

debug 'Sending API request to Codecov API'
RESPONSE=$(
	curl --silent \
		--write-out '%{http_code}' \
		--data-binary "@./${FILE}" \
		https://codecov.io/validate
)

debug 'Mapping response to an array of lines'
mapfile -t RESPONSE_LINES <<<"${RESPONSE}"

debug 'Extracting response code from response'
RESPONSE_CODE=${RESPONSE_LINES[-1]}
echo "status-code=${RESPONSE_CODE}" >>"${GITHUB_OUTPUT}"

debug 'Logging response body'
echo '::group::Codecov API response'
for line in "${RESPONSE_LINES[@]::${#RESPONSE_LINES[@]}-1}"; do
	echo "${line}"
done
echo '::endgroup::'

debug 'Evaluating result'
if [ "${RESPONSE_CODE}" == '200' ]; then
	echo 'Codecov configuration is valid.'
	exit 0
elif [ "${RESPONSE_CODE}" -ge '400' ] && [ "${RESPONSE_CODE}" -lt '500' ]; then
	echo "Codecov configuration is invalid (got ${RESPONSE_CODE})."
	echo ''
	echo "Update the Codecov configuration file at ${FILE} to make it valid."
	exit 1
elif [ "${RESPONSE_CODE}" -ge '500' ]; then
	echo "Codecov configuration could not be validated (got ${RESPONSE_CODE})."
	echo ''
	echo 'You can try to rerun this job after a short delay and it should pass then.'
	echo "If the exact response code ${RESPONSE_CODE} persists, verify Codecov does not have an outage."
	exit 1
else
	echo "Codecov configuration validation state unknown (got ${RESPONSE_CODE})."
	echo ''
	echo 'If this persists open an issue at:'
	echo 'https://github.com/ericcornelissen/codecov-config-validator-action/issues/new'
	exit 1
fi
