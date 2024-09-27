# terraform-azurerm-altinn-modules
Terraform modules created by Altinn

This repository holds a set of modules defined as submodules maintained by team-platform. The maintenance is besteffort and some submodules might be deprecated and removed in later releases

Please read the releasenotes for more information on changes from one version to another

## Submodules

### container_apps_job_github_runner

(Documentation)[modules/github_runner_container_apps_job]

Module for deploying a container apps environment with a container app jobs that acts as self hosted github runners.

These self hosted runners should only be used if strictly necessary as the might pose a security risk.

## Contributing
### Add new submodule
Run the make command: `SUBMODULE=<name-of-new-submodule> make add-new-submodule`

### Generate updated docs
To update the docs:
1. Install (terraform-docs)[https://terraform-docs.io/]
2. Run `SUBMODULE=<name-of-submodule> make generate-docs` example: `SUBMODULE=github_runner_container_apps_job make generate-docs`

Or
1. Install (terraform-docs)[https://terraform-docs.io/]
2. Change directory to the submodule you want to update the docs for `cd modules/<name-of-submodule>`
3. Run `make generate-docs`
