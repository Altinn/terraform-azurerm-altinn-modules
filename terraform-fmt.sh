#!/bin/bash
MODULE=""
ALL=no
while [[ $# -gt 0 ]]; do
  case $1 in
    --module)
      MODULE="$2"
      shift # pop option
      shift # pop value
      ;;
    --all)
      ALL=yes
      shift #pop option
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

if [[ "${ALL}" == "yes" ]]; then
    echo "Terraform fmt all modules"
    for D in modules/*; do
        if [ -d "${D}" ]; then
            echo "Formating ${D}"
            pushd ${D} > /dev/null
            terraform fmt
            popd > /dev/null
        fi
    done
    exit 0
elif [[ -n "$MODULE" ]]; then
    if [[ -d "modules/${MODULE}" ]]; then
        pushd modules/${MODULE} > /dev/null
        terraform fmt
        popd > /dev/null
    else
        echo "Module with name ${MODULE} not found in modules/ folder"
        exit 1
    fi
else
    echo "Either give a specific module with the --module flag or use the --all flag"
    exit 1
fi