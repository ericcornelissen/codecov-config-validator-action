#!/bin/bash

RESULT=$(
	curl --silent \
		--output "/dev/null" \
		--write-out "%{http_code}" \
		--data-binary "@./${FILE}" \
		https://codecov.io/validate
)

echo "status-code=${RESULT}" >>"${GITHUB_OUTPUT}"

if [ "${RESULT}" != "200" ]; then
	echo "Codecov configuration is invalid (got ${RESULT})"
	exit 1
else
	echo "Codecov configuration is valid"
fi
