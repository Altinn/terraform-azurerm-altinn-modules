SUBMODULE ?= 

.PHONY: add-new-submodule
add-new-submodule:
	mkdir modules/${SUBMODULE}
	echo '.PHONY: generate-readme\ngenerate-readme:\n	cat base.md > README.md\n	terraform-docs markdown --hide-empty table . >> README.md"' > modules/${SUBMODULE}/Makefile
	echo '## Example Usage\n```\nTODO: Provide example usage of this submodule\n```\n' > modules/${SUBMODULE}/base.md

.PHONY: generate-docs
generate-docs:
	cd modules/${SUBMODULE} && make generate-docs