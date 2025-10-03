# terraform-azurerm-altinn-modules
Terraform modules created by Altinn.

This repository holds a set of modules defined as submodules maintained by the platform team.

The maintenance is best-effort and some submodules might be deprecated and removed in later releases.

Please read the release notes for more information on changes from one version to another.

## Submodules

### container_apps_job_github_runner

Module for deploying a container apps environment with a container app jobs that acts as self hosted github runners.

These self hosted runners should only be used if strictly necessary as they might pose a security risk.

[Documentation](modules/github_runner_container_app_jobs)

## Contributing
### Add a new submodule
Run the shell script `add-new.sh` 

For example: `./add-new.sh --name new-example-submodule`

### Generate updated docs
Firstly, Install [terraform-docs](https://terraform-docs.io/).

#### To update the docs for all submodules
run the script `generate-docs.sh` with the flag `--all`.

`./generate-docs.sh --all`

#### To update the the docs for one submodule 
run the script `generate-docs.sh` with the flag `--module <submodulename>`

For example: `./generate-docs.sh --module github_runner_container_apps_job`

Or you can also change directory to the submodule you want to update the docs for e.g. `cd modules/<name-of-submodule>` and run 

`make generate-docs`.
