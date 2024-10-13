DOCKER_TAG_VERSION_DEVELOPER_TOOLS := 1.3
DOCKER_IMAGE_DEVELOPER_TOOLS := cft/developer-tools
REGISTRY_URL := gcr.io/cloud-foundation-cicd

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

$(BIN_PATH):
	mkdir -p $(BIN_PATH)

ifeq (,$(shell go env GOBIN))
export GOBIN=$(BUILD_DIR)/gobin
else
export GOBIN=$(shell go env GOBIN)
endif
export PATH:=${GOBIN}:${PATH}

# VCSIM ?= $(BIN_PATH)/vcsim

#define go-install-tool
#@[ -f $(1) ] || { \
#set -e ;\
#TMP_DIR=$$(mktemp -d) ;\
#cd $$TMP_DIR ;\
#go mod init tmp ;\
#echo "Downloading $(2)" ;\
#env -i bash -c "GOBIN=$(GOBIN) PATH=$(PATH) GOPATH=$(shell go env GOPATH) GOCACHE=$(shell go env GOCACHE) go install $(2)" ;\
#rm -rf $$TMP_DIR ;\
#}
#endef

#.PHONY: vet
#vet: ## Run go vet against code.
#	go vet ./...

#.PHONY: vcsim
#vcsim: $(VCSIM) ## Download vcsim locally if necessary.
#$(VCSIM): $(BIN_PATH)
#	test -s $(BIN_PATH)/vcsim || GOBIN=$(BIN_PATH) go install github.com/vmware/govmomi/vcsim@latest

.PHONY: fmt
fmt: ## Terraform fmt
	terraform fmt --check --recursive


.PHONY: lint
lint:  ## Run go/terraform linter
	go vet ./...
	tflint --recursive

test: ## Execute Go tests
	PATH=$(BIN_PATH):$$PATH \
	go test ./... -coverprofile cover.out
##	-v

.PHONY: generate_docs
generate_docs: ## Generate documentation
	docker run --rm -it \
		-v $(CURDIR):/workspace \
		$(REGISTRY_URL)/${DOCKER_IMAGE_DEVELOPER_TOOLS}:${DOCKER_TAG_VERSION_DEVELOPER_TOOLS} \
		/bin/bash -c 'source /usr/local/bin/task_helper_functions.sh && generate_docs'	
