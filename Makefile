TEST_FILES:=test/test_*.sh
SHELL_SCRIPTS:=bin/*.sh lib/*.sh $(TEST_FILES)

GITHUB_OUTPUT:=github_output

.PHONY: default
default: help

.PHONY: clean
clean: ## Clean the repository
	@git clean -fx \
		$(GITHUB_OUTPUT)

.PHONY: format format-check
format: ## Format the source code
	@shfmt \
		--simplify \
		--write \
		$(SHELL_SCRIPTS)

format-check: ## Check the source code formatting
	@shfmt \
		--diff \
		$(SHELL_SCRIPTS)

.PHONY: help
help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
		printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

.PHONY: lint lint-ci lint-sh lint-yml
lint: lint-ci lint-sh lint-yml ## Run lint-*

lint-ci: ## Lint CI workflows
	@actionlint

lint-sh: ## Lint .sh files
	@shellcheck \
		$(SHELL_SCRIPTS)

lint-yml: ## Lint .yml files
	@yamllint \
		-c .yamllint.yml \
		.

.PHONY: release
release: ## Release a new version
ifneq "$(shell git branch --show-current)" "main"
	@echo 'refusing to release, not on main branch'
	@echo 'first run: "git switch main"'
else ifeq "$v" ""
	@echo 'usage: "make release v=1.0.1"'
else
	@git tag "v$v"
	@git push origin "v$v"
endif

.PHONY: test test-e2e test-run
test: ## Run the automated tests
	@echo 'Testing valid config...'
	@test/test_valid.sh
	@echo ''
	@echo 'Testing invalid config...'
	@test/test_invalid.sh
	@echo ''
	@echo 'Testing server error...'
	@test/test_error.sh
	@echo ''
	@echo 'Testing unexpected response...'
	@test/test_unexpected.sh

test-run: ## Run the action locally
	@rm -f ${GITHUB_OUTPUT}
	@touch ${GITHUB_OUTPUT}
	@( \
		API_URL="https://codecov.io" \
		FILE="testdata/codecov.yml" \
		GITHUB_OUTPUT="${GITHUB_OUTPUT}" \
		./bin/validate.sh \
	)

.PHONY: verify
verify: format-check lint test ## Verify project is in a good state
