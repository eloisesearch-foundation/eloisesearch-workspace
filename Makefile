.DEFAULT_GOAL := help
.PHONY: help setup setup-all pull status workspace docs-new-design docs-check changelog-check

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

setup: ## Clone core repositories as siblings
	@scripts/bootstrap.sh

setup-all: ## Clone core and SDK/integration repositories
	@scripts/bootstrap.sh --all

pull: ## Fast-forward every cloned repository
	@scripts/bootstrap.sh --all --pull

status: ## Branch, ahead/behind and local changes for every repository
	@scripts/status.sh

workspace: ## Open the multi-root workspace in VS Code
	@code eloisesearch.code-workspace

docs-new-design: ## New design doc: make docs-new-design NAME=<topic> [REPO=eloisesearch]
	@scripts/new-design.sh "$(NAME)" "$(or $(REPO),eloisesearch)"

docs-check: ## Report broken relative links in Markdown across all cloned repos
	@python3 scripts/check-docs.py

changelog-check: ## Validate CHANGELOG.md in every cloned repo that ships the check
	@scripts/each.sh sh -c 'if [ -x scripts/check-changelog.sh ]; then scripts/check-changelog.sh; else echo "no changelog check"; fi'
