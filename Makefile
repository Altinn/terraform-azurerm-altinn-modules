NAME ?= 

.PHONY: add-new-submodule
add-new-submodule:
	./add-new --name=${NAME}

.PHONY: generate-docs
generate-docs:
	./generate-docs.sh --all