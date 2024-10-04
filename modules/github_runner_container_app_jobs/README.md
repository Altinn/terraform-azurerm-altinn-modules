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
  service_endpoints    = ["Microsoft.KeyVault"]
}

module "hello-modules_container-apps-gh-runners" {
  source                   = "Altinn/altinn-modules/azurerm//modules/github_runner_container_app_jobs"
  version                  = "0.0.1" #See releases for latest version
  app_id                   = "321321321"
  install_id               = "123123123"
  app_key                  = "PHNlY3JldC1hcHAta2V5Pgo="
  repos                    = [
    {
      owner: "Altinn"
      name: "terraform-azurerm-altinn-modules
    },
    {
      owner: "Altinn"
      name: "altinn-platform"
    }
  ]
  resource_prefix          = example
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name      = azurerm_resource_group.example.name
}
```

Resources will inherit location from resource group

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.116.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.116.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.6.3 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.acaghr_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_job.acaghr_app_job](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |
| [azurerm_key_vault.acaghr_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.acaghr_app_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_user_assigned_identity.acaghr_managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.acaghr_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags that should be added to all resources. Concated with the default tags | `map(string)` | `{}` | no |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Github App Id | `string` | n/a | yes |
| <a name="input_app_key"></a> [app\_key](#input\_app\_key) | Base64 encoded Github app private key | `string` | n/a | yes |
| <a name="input_infrastructure_subnet_id"></a> [infrastructure\_subnet\_id](#input\_infrastructure\_subnet\_id) | The subnet\_id where the container app jobs are running. The Subnet must have a /21 or larger address space. | `string` | n/a | yes |
| <a name="input_install_id"></a> [install\_id](#input\_install\_id) | Github Installation Id | `string` | n/a | yes |
| <a name="input_kv_ip_rules"></a> [kv\_ip\_rules](#input\_kv\_ip\_rules) | IPs that will be allowed to access the KV holding the secrets needed by the environment | `set(string)` | `[]` | no |
| <a name="input_repos"></a> [repos](#input\_repos) | Set of repos there should be created a job for running actiosn. Each owner/repo will get it's own azure container app job in the environsment | <pre>set(object({<br/>    owner = string<br/>    name  = string<br/>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that the resources should be placed in. Check for naming conflicts. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resources | `string` | n/a | yes |
| <a name="input_runner_cpu"></a> [runner\_cpu](#input\_runner\_cpu) | CPU allocated to a runner | `string` | `"0.5"` | no |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | Docker image to run when a job is scheduled | `string` | `"ghcr.io/Altinn/altinn-platform/gh-runner:latest"` | no |
| <a name="input_runner_labels"></a> [runner\_labels](#input\_runner\_labels) | Additional labels to add to the runner | `string` | `"default"` | no |
| <a name="input_runner_max_running_jobs"></a> [runner\_max\_running\_jobs](#input\_runner\_max\_running\_jobs) | Maximum number of jobs to run at one time | `string` | `"20"` | no |
| <a name="input_runner_memory"></a> [runner\_memory](#input\_runner\_memory) | Memory allocated to a runner | `string` | `"1Gi"` | no |
