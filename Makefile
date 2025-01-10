.PHONY: generate-docs
generate-docs:
	./generate-docs.sh --all

fmt:
	./terraform-fmt.sh --all