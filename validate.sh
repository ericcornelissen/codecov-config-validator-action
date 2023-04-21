#!/bin/bash

RESULT=$(
	curl --silent \
		--output "/dev/null" \
		--write-out "%{http_code}" \
		--data-binary "@./${FILE}" \
		https://codecov.io/validate
)

echo "status-code=${RESULT}" >>"${GITHUB_OUTPUT}"

if [ "${RESULT}" == "200" ]; then
	echo "Codecov configuration is valid."
	exit 0
elif [ "${RESULT}" -ge "400" ] && [ "${RESULT}" -lt "500" ]; then
	echo "Codecov configuration is invalid (got ${RESULT})."
	echo ''
	echo "Update the Codecov configuration file at ${FILE} to make it valid."
	exit 1
elif [ "${RESULT}" -ge "500" ]; then
	echo "Codecov configuration could not be validated (got ${RESULT})."
	echo ''
	echo "You can try to rerun this job after a short delay and it should pass then."
	echo "If the exact response code ${RESULT} persists, verify Codecov does not have an outage."
	exit 1
else
	echo "Codecov configuration validation state unknown (got ${RESULT})."
	echo ''
	echo 'If this persists open an issue at:'
	echo 'https://github.com/ericcornelissen/codecov-config-validator-action/issues/new'
	exit 1
fi
