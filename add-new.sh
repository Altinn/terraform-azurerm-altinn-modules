#!/bin/bash
NAME=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      NAME="$2"
      shift # pop option
      shift # pop value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unknown argument $1"
      exit 1
      ;;
  esac
done


if [[ -z "${NAME}" ]]; then
    echo "Please give a name with the --name flag"
    exit 1
fi

if [[ -d "modules/${NAME}" ]]; then
    echo "Module with name ${NAME} already exists."
    exit 1
fi

mkdir modules/${NAME}

pushd modules/${NAME}
cat <<EOF >> Makefile
.PHONY: generate-docs
generate-docs:
	cat base.md > README.md
	terraform-docs markdown --hide-empty table . >> README.md
EOF
cat <<EOF >> base.md
## Example

```
TODO: Provide an example of how this modules can be used
```
EOF
popd