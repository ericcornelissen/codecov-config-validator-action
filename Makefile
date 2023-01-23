GITHUB_OUTPUT:=github_output

default: help

clean: ## Clean the repository
	@git clean -fx \
		$(GITHUB_OUTPUT)

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
		printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

lint-ci: $(ASDF) ## Lint CI workflows
	@actionlint

lint-md: ## Lint .md files
	@markdownlint \
		--config .markdownlint.yml \
		--dot \
		--ignore-path .gitignore \
		.

lint-sh: ## Lint .sh files
	@shellcheck \
		validate.sh

lint-yml: ## Lint .yml files
	@yamllint \
		-c .yamllint.yml \
		.

release: ## Release a new version
ifeq "$v" ""
	@echo 'usage: "make release v=1.0.1"'
else
	@git tag "v$v"
	@git push origin "v$v"
endif

test-run: ## Run the action locally
	@rm -f ${GITHUB_OUTPUT}
	@touch ${GITHUB_OUTPUT}
	@( \
		FILE="testdata/codecov.yml" \
		GITHUB_OUTPUT="${GITHUB_OUTPUT}" \
		./validate.sh \
	)

.PHONY: clean default help lint-ci lint-md lint-sh lint-yml release test-run
