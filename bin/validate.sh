#!/bin/bash
# SPDX-License-Identifier: MPL-2.0

# shellcheck source=./lib/actions.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/actions.sh"

# ---------------------------------------------------------------------------- #

debug 'Sending API request to Codecov API'
RESPONSE=$(
	curl --silent \
		--write-out '%{http_code}' \
		--data-binary "@./${FILE}" \
		"${API_URL}/validate"
)

debug 'Mapping response to an array of lines'
mapfile -t RESPONSE_LINES <<<"${RESPONSE}"

debug 'Extracting response code from response'
RESPONSE_CODE=${RESPONSE_LINES[-1]}
set_output 'status-code' "${RESPONSE_CODE}"

debug 'Logging response body'
group_start 'Codecov API response'
for line in "${RESPONSE_LINES[@]::${#RESPONSE_LINES[@]}-1}"; do
	info "${line}"
done
group_end

debug 'Evaluating result'
if [ "${RESPONSE_CODE}" == '200' ]; then
	info 'Codecov configuration is valid.'
	exit 0
elif [ "${RESPONSE_CODE}" -ge '400' ] && [ "${RESPONSE_CODE}" -lt '500' ]; then
	info "Codecov configuration is invalid (got ${RESPONSE_CODE})."
	info ''
	info "Update the Codecov configuration file at ${FILE} to make it valid."
	exit 1
elif [ "${RESPONSE_CODE}" -ge '500' ]; then
	info "Codecov configuration could not be validated (got ${RESPONSE_CODE})."
	info ''
	info 'You can try to rerun this job after a short delay and it should pass then.'
	info "If the exact response code ${RESPONSE_CODE} persists, verify Codecov does not have an outage."
	exit 1
else
	info "Codecov configuration validation state unknown (got ${RESPONSE_CODE})."
	info ''
	info 'If this persists open an issue at:'
	info 'https://github.com/ericcornelissen/codecov-config-validator-action/issues/new'
	exit 1
fi
