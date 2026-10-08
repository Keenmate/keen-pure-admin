# --- Windows recipe-shell fix -------------------------------------------------
# When make is launched from PowerShell / cmd.exe, GNU make picks cmd.exe as the
# recipe shell — which has no grep/awk/xargs, so the bash pipelines in these
# targets (kill-port, themes-install, the podman-* checks) die with "The system
# cannot find the file specified". Pinning the recipe shell to Git's full bash
# launcher makes every recipe run under Git Bash regardless of the launching
# shell. Guarded by $(wildcard) so it's a no-op when Git isn't at the default
# location (falls back to make's normal shell selection).
ifeq ($(OS),Windows_NT)
  # NB: the existence check uses `?` for the space in "Program Files" — a literal
  # space would make $(wildcard) split it into two patterns that never match.
  # The SHELL assignment itself keeps the real (spaced) path.
  ifneq ($(wildcard C:/Program?Files/Git/bin/bash.exe),)
    SHELL := C:/Program Files/Git/bin/bash.exe
  endif
endif
# -----------------------------------------------------------------------------

.PHONY: help setup dev kill-port build publish publish-dry deps test fidelity format quality docs docs-serve clean themes-install themes-clear podman-build podman-run podman-stop podman-restart podman-logs podman-clean podman-deploy podman-push

# Demo server port (config/runtime.exs reads PORT, default 18700).
# Override: make kill-port PORT=xxxx
PORT ?= 18700

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: deps themes-install ## Install deps, snapshot themes, and compile library + demo
	mix compile
	cd demo && mix compile

deps: ## Install dependencies for library and demo
	mix deps.get
	cd demo && mix deps.get

# Snapshot themes into demo/priv/static/themes/ from configured sources
# (remote API via demo/pureadmin.json + lock OR local sibling paths via
# demo/.pureadmin.json). Skips silently if neither config exists — handy on
# fresh clones before configs are written.
themes-install: ## Snapshot themes into demo/priv/static/themes/
	@if [ -f demo/pureadmin.json ] || [ -f demo/.pureadmin.json ]; then \
		cd demo && npx @keenmate/pureadmin themes install; \
	else \
		echo "themes-install: no demo/pureadmin.json or demo/.pureadmin.json — skipping"; \
	fi

dev: themes-install ## Snapshot themes and start demo app with iex
	cd demo && iex -S mix phx.server

# Free the demo server port (e.g. after a crashed/orphaned `make dev` leaves the
# port held). Override the port with: make kill-port PORT=18701
# Uses netstat|awk|taskkill on Windows (run under Git Bash) rather than cmd.exe
# `for /f`; lsof elsewhere. The leading `-` ignores "nothing to kill" as success.
kill-port: ## Free the demo server port (default 18700; override with PORT=xxxx)
	@echo "Freeing port $(PORT)..."
ifeq ($(OS),Windows_NT)
	-@netstat -ano | grep LISTENING | grep ":$(PORT) " | awk '{print $$5}' | sort -u | xargs -r -I{} taskkill //F //PID {}
else
	-@lsof -ti tcp:$(PORT) | xargs -r kill -9
endif
	@echo "Port $(PORT) is free"

build: ## Build hex package
	mix hex.build

publish: ## Publish to hex.pm
	mix hex.publish

publish-dry: ## Dry-run hex publish
	mix hex.publish --dry-run

test: ## Run tests
	mix test

fidelity: ## Re-dump ALL fidelity scenarios fresh, then run the core markup + coverage gate (dumps are gitignored → re-dumping IS the freshness guarantee)
	mix pa.fidelity.dump --all
	node ../pure-admin/packages/core/fidelity/compare-all.mjs --wrapper keen

format: ## Format code in library and demo
	mix format
	cd demo && mix format

quality: ## Run format check + credo + dialyzer
	mix quality

docs: ## Generate documentation
	mix docs

docs-serve: docs ## Generate and serve docs on port 5555
	npx five-server doc --port 5555

clean: ## Clean build artifacts
	mix clean
	cd demo && mix clean

themes-clear: ## Clear cached themes (forces re-download on next access)
	cd demo && mix eval 'File.rm_rf!(Path.join(System.tmp_dir!(), "pure-admin-themes")); IO.puts("Theme cache cleared")'

# === Docker Commands ===
# Docker image settings
DOCKER_IMAGE_NAME = keen-pure-admin-demo
DOCKER_REGISTRY = registry.km8.es
DOCKER_TAG = production
DOCKER_CONTAINER_NAME = keen-pure-admin-demo
DOCKER_PORT = 4000

podman-build: ## Build Docker image
	@echo "Building Docker image: $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)"
	podman build -t $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) .
	@echo "Docker image built successfully!"

podman-run: ## Run Docker container
	@echo "Starting Docker container on port $(DOCKER_PORT)"
	@if [ $$(podman ps -q -f name=$(DOCKER_CONTAINER_NAME)) ]; then \
		echo "Container is already running at http://localhost:$(DOCKER_PORT)"; \
	elif [ $$(podman ps -aq -f name=$(DOCKER_CONTAINER_NAME)) ]; then \
		echo "Starting existing container"; \
		podman start $(DOCKER_CONTAINER_NAME); \
		echo "Application is running at: http://localhost:$(DOCKER_PORT)"; \
	else \
		echo "Creating and starting new container"; \
		podman run -d --name $(DOCKER_CONTAINER_NAME) -p $(DOCKER_PORT):4000 \
			-e SECRET_KEY_BASE=$${SECRET_KEY_BASE:-$$(mix phx.gen.secret)} \
			-e PHX_HOST=$${PHX_HOST:-localhost} \
			$(DOCKER_IMAGE_NAME):$(DOCKER_TAG); \
		echo "Application is running at: http://localhost:$(DOCKER_PORT)"; \
	fi

podman-stop: ## Stop Docker container
	@echo "Stopping Docker container"
	@if [ $$(podman ps -q -f name=$(DOCKER_CONTAINER_NAME)) ]; then \
		podman stop $(DOCKER_CONTAINER_NAME); \
		echo "Container stopped successfully"; \
	else \
		echo "Container is not running"; \
	fi

podman-restart: podman-stop podman-run ## Restart Docker container

podman-logs: ## Show Docker container logs
	@if [ $$(podman ps -aq -f name=$(DOCKER_CONTAINER_NAME)) ]; then \
		podman logs -f $(DOCKER_CONTAINER_NAME); \
	else \
		echo "Container does not exist"; \
	fi

podman-clean: podman-stop ## Remove Docker container and image
	@echo "Cleaning up Docker resources"
	@if [ $$(podman ps -aq -f name=$(DOCKER_CONTAINER_NAME)) ]; then \
		podman rm $(DOCKER_CONTAINER_NAME); \
		echo "Container removed"; \
	fi
	@if [ $$(podman images -q $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)) ]; then \
		podman rmi $(DOCKER_IMAGE_NAME):$(DOCKER_TAG); \
		echo "Image removed"; \
	fi

podman-deploy: podman-build podman-run ## Build and run Docker container

podman-push: ## Tag and push image to registry
	@echo "Tagging and pushing image to $(DOCKER_REGISTRY)"
	podman tag $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)
	podman push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)
	@echo "Image pushed to $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME):$(DOCKER_TAG)"
