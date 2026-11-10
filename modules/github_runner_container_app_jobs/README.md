## Example Usage

```terraform
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/21"]

  service_endpoint {
    service = "Microsoft.KeyVault"
  }
}

module "hello-modules_container-apps-gh-runners" {
  source     = "Altinn/altinn-modules/azurerm//modules/github_runner_container_app_jobs"
  version    = "2.0.0" #See releases for latest version
  app_id     = "321321321"
  install_id = "123123123"
  app_key    = "PHNlY3JldC1hcHAta2V5Pgo="
  owner = "Altinn"
  repos = [
    "terraform-azurerm-altinn-modules",
    "altinn-platform"
  ]
  resource_prefix          = "example"
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name      = azurerm_resource_group.example.name

  # Optional: reduce GitHub API usage of the KEDA scaler
  # polling_interval_in_seconds = 30   # default 20
  # scaler_enable_etags         = true # default false, conditional requests (304s are not rate limited)

  # Optional: pull the runner image from a private ACR with the job's managed identity.
  # The identity gets read access to the runner_image repository only (requires ABAC
  # repository permissions on the registry).
  # runner_image       = "myacr.azurecr.io/altinn-platform/gh-runner:v1.2.3"
  # container_registry = { id = azurerm_container_registry.example.id }
}
```

Resources will inherit location from resource group

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=5.0.0, <6.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=5.0.0, <6.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.6.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_container_app_environment.acaghr_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_job.acaghr_app_job](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |
| [azurerm_key_vault.acaghr_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.acaghr_app_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.acaghr_registry_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.acaghr_managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.job_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.acaghr_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags that should be added to all resources. Concated with the default tags | `map(string)` | `{}` | no |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Github App Id | `string` | n/a | yes |
| <a name="input_app_key"></a> [app\_key](#input\_app\_key) | Base64 encoded Github app private key | `string` | n/a | yes |
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | Pull runner\_image from a private Azure Container Registry with the job's managed identity. The registry server and repository are taken from runner\_image. Leave null to pull anonymously (for example from ghcr.io).<br/>id: resource id of the registry. Required when create\_role\_assignment is true.<br/>create\_role\_assignment: grant the identity "Container Registry Repository Reader" on the registry, limited with an ABAC condition to the runner\_image repository. The registry must use ABAC repository permissions, and the deploying principal must be allowed to create role assignments on it. Set to false to grant access outside the module, using the identity\_principal\_id output. | <pre>object({<br/>    id                     = optional(string)<br/>    create_role_assignment = optional(bool, true)<br/>  })</pre> | `null` | no |
| <a name="input_infrastructure_subnet_id"></a> [infrastructure\_subnet\_id](#input\_infrastructure\_subnet\_id) | The subnet\_id where the container app jobs are running. The Subnet must have a /21 or larger address space. | `string` | n/a | yes |
| <a name="input_install_id"></a> [install\_id](#input\_install\_id) | Github Installation Id | `string` | n/a | yes |
| <a name="input_internal_load_balancer_enabled"></a> [internal\_load\_balancer\_enabled](#input\_internal\_load\_balancer\_enabled) | Run the container app environment in internal load balancing mode, so that it reserves an IP in infrastructure\_subnet\_id instead of a public one. The runner jobs only make outbound connections, so they do not need a public endpoint. Public network access on the environment is disabled in this mode, as required by the provider. Changing this forces the container app environment, and every job in it, to be recreated. | `bool` | `false` | no |
| <a name="input_kv_ip_rules"></a> [kv\_ip\_rules](#input\_kv\_ip\_rules) | IPs that will be allowed to access the KV holding the secrets needed by the environment | `set(string)` | `[]` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Github owner or organization | `string` | n/a | yes |
| <a name="input_polling_interval_in_seconds"></a> [polling\_interval\_in\_seconds](#input\_polling\_interval\_in\_seconds) | How often (in seconds) the KEDA github-runner scaler polls the GitHub API for queued jobs. Each poll costs at least 2 API calls per repo against the GitHub App installation rate limit. | `number` | `20` | no |
| <a name="input_repos"></a> [repos](#input\_repos) | Set of repos there should be created a job for running actiosn. Each owner/repo will get it's own azure container app job in the environsment | `set(string)` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that the resources should be placed in. Check for naming conflicts. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resources | `string` | n/a | yes |
| <a name="input_runner_cpu"></a> [runner\_cpu](#input\_runner\_cpu) | CPU allocated to a runner | `string` | `"0.5"` | no |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | Docker image to run when a job is scheduled | `string` | `"ghcr.io/Altinn/altinn-platform/gh-runner:latest"` | no |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | Additional labels to add to the runner | `string` | `"default"` | no |
| <a name="input_runner_max_running_jobs"></a> [runner\_max\_running\_jobs](#input\_runner\_max\_running\_jobs) | Maximum number of jobs to run at one time | `string` | `"20"` | no |
| <a name="input_runner_memory"></a> [runner\_memory](#input\_runner\_memory) | Memory allocated to a runner | `string` | `"1Gi"` | no |
| <a name="input_runner_replica_timeout"></a> [runner\_replica\_timeout](#input\_runner\_replica\_timeout) | The maximum number of seconds a runner replica is allowed to run | `number` | `7200` | no |
| <a name="input_scaler_enable_etags"></a> [scaler\_enable\_etags](#input\_scaler\_enable\_etags) | Enable conditional requests (ETags) in the KEDA github-runner scaler. Unchanged responses (HTTP 304) do not count against the GitHub API rate limit. When false the enableEtags key is not sent to the scaler at all. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_azurerm_container_app_environment_name"></a> [azurerm\_container\_app\_environment\_name](#output\_azurerm\_container\_app\_environment\_name) | n/a |
| <a name="output_azurerm_container_app_runner_job_names"></a> [azurerm\_container\_app\_runner\_job\_names](#output\_azurerm\_container\_app\_runner\_job\_names) | n/a |
| <a name="output_azurerm_key_vault_id"></a> [azurerm\_key\_vault\_id](#output\_azurerm\_key\_vault\_id) | n/a |
| <a name="output_azurerm_key_vault_name"></a> [azurerm\_key\_vault\_name](#output\_azurerm\_key\_vault\_name) | n/a |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | Resource id of the user assigned identity used by the runner jobs |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal (object) id of the user assigned identity used by the runner jobs. Use it to grant registry access when container\_registry.create\_role\_assignment is false |
