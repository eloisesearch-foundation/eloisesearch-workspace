.DEFAULT_GOAL := help
.PHONY: help setup setup-all pull status workspace

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

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
