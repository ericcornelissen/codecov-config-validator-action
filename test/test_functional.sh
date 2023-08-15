#!/usr/bin/env bash

API_URL='localhost:8080'
FILE='testdata/codecov.yml'
GITHUB_OUTPUT='github_output'

setup() {
	rm -f "${GITHUB_OUTPUT}"
}

test_example() {
	API_URL="${API_URL}" \
		FILE="${FILE}" \
		GITHUB_OUTPUT="${GITHUB_OUTPUT}" \
		./validate.sh \

	actual="$(cat "${GITHUB_OUTPUT}")"
	expected="status-code=200"

	assertEquals "${actual}" "${expected}"
}
