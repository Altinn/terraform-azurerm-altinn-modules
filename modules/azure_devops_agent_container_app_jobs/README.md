## Example Usage

```terraform
resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "Norway East"
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
  address_prefixes     = ["10.0.0.0/21"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

module "hello-modules_container-apps-agent" {
  depends_on               = [azurerm_resource_group.example]
  source                   = "Altinn/altinn-modules/azurerm//modules/azure_devops_agent_container_app_jobs"
  version                  = "1.0.1"
  azp_org_url              = "https://dev.azure.com/example"
  azp_token                = "U29Zb3VUb3VnaHRJV2FzSVJlYWxQYXQ/QnV0VGhhdElBaW4ndA=="
  resource_prefix          = "example"
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name      = azurerm_resource_group.example.name

  agent_env_variables = {
    HTTP_PROXY = "http://proxy.example.com:3128"
  }
  agent_env_secrets = {
    EXTRA_SECRET = "not-a-real-secret"
  }
}
```

Resources will inherit location from resource group

Hosts IP will automatically be added to the allow list in the firewall. Remember to remove it from the list if desirable.

## Environment variables

`agent_env_variables` and `agent_env_secrets` add environment variables to the agent job. The
placeholder job is not affected. `AZP_URL`, `AZP_TOKEN` and `AZP_POOL` are set by the module and
can not be overridden through either input.

`agent_env_secrets` takes the secret *value*. The module stores it as a secret in the key vault it
creates, grants its own managed identity read access, and mounts it on the agent job. The caller
never touches the key vault.

Each environment variable name is lower cased with underscores replaced by dashes to form the
container app secret name, so `EXTRA_SECRET` is mounted as the secret `extra-secret` on the job and
stored in the key vault as `<resource_prefix>-extra-secret`.

Values passed through `agent_env_secrets` end up in terraform state, the same as `azp_token`. Treat
state as sensitive.

### Changed in 1.4.0

In 1.3.0 `agent_env_secrets` took versionless key vault secret ids, expecting the caller to create
the secret in the vault exposed by the `azurerm_key_vault_id` output. That could not work: a
`depends_on` on the module block makes every module output depend on every resource in the module,
so the output depended on the agent job while the job depended on the caller's secret, which
depended on the output. Terraform rejected it as a dependency cycle.

If you were on 1.3.0, pass the value instead of the id and delete your own
`azurerm_key_vault_secret` resource:

```terraform
# 1.3.0
resource "azurerm_key_vault_secret" "extra" {
  name         = "example-extra-secret"
  value        = var.extra_secret
  key_vault_id = module.agent.azurerm_key_vault_id
}
agent_env_secrets = { EXTRA_SECRET = azurerm_key_vault_secret.extra.versionless_id }

# 1.4.0
agent_env_secrets = { EXTRA_SECRET = var.extra_secret }
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.14.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >=3.4.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.14.0 |
| <a name="provider_http"></a> [http](#provider\_http) | >=3.4.5 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.6.3 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_container_app_environment.agent_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_container_app_job.agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |
| [azurerm_container_app_job.placeholder_agent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_job) | resource |
| [azurerm_key_vault.agent_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.agent_env](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.azp_org_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.azp_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_user_assigned_identity.agent_managed_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_string.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.agent_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [http_http.host_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags that should be added to all resources. Concatenated with the default tags | `map(string)` | `{}` | no |
| <a name="input_agent_cpu"></a> [agent\_cpu](#input\_agent\_cpu) | CPU allocated to a runner | `string` | `"0.5"` | no |
| <a name="input_agent_env_secrets"></a> [agent\_env\_secrets](#input\_agent\_env\_secrets) | Additional secret environment variables for the agent container. Map key is the environment variable name, map value is the secret value. The module stores each value as a secret in the key vault it creates and mounts it on the agent job. AZP\_URL, AZP\_TOKEN and AZP\_POOL are set by the module and can not be overridden. | `map(string)` | `{}` | no |
| <a name="input_agent_env_variables"></a> [agent\_env\_variables](#input\_agent\_env\_variables) | Additional plain text environment variables for the agent container. Map key is the environment variable name, map value is its value. AZP\_URL, AZP\_TOKEN and AZP\_POOL are set by the module and can not be overridden. | `map(string)` | `{}` | no |
| <a name="input_agent_image"></a> [agent\_image](#input\_agent\_image) | Docker image to run when a job is scheduled | `string` | `"ghcr.io/altinn/altinn-platform/azure-devops-agent:v1.0.0"` | no |
| <a name="input_agent_max_running_jobs"></a> [agent\_max\_running\_jobs](#input\_agent\_max\_running\_jobs) | Maximum number of jobs to run at one time | `string` | `"20"` | no |
| <a name="input_agent_memory"></a> [agent\_memory](#input\_agent\_memory) | Memory allocated to a runner | `string` | `"1Gi"` | no |
| <a name="input_agent_pool_name"></a> [agent\_pool\_name](#input\_agent\_pool\_name) | Name of the agent pool in azure devops | `string` | n/a | yes |
| <a name="input_agent_replica_timeout"></a> [agent\_replica\_timeout](#input\_agent\_replica\_timeout) | The maximum number of seconds a agent replica is allowed to run | `number` | `7200` | no |
| <a name="input_azp_org_url"></a> [azp\_org\_url](#input\_azp\_org\_url) | URL for your Azure DevOps organization | `string` | n/a | yes |
| <a name="input_azp_token"></a> [azp\_token](#input\_azp\_token) | Base64 encoded Azure Devops PAT | `string` | n/a | yes |
| <a name="input_infrastructure_subnet_id"></a> [infrastructure\_subnet\_id](#input\_infrastructure\_subnet\_id) | The subnet\_id where the container app jobs are running. The Subnet must have a /21 or larger address space. | `string` | n/a | yes |
| <a name="input_kv_ip_rules"></a> [kv\_ip\_rules](#input\_kv\_ip\_rules) | IPs that will be allowed to access the KV holding the secrets needed by the environment | `set(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group that the resources should be placed in. Check for naming conflicts. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resources | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_azurerm_container_app_agent_job_name"></a> [azurerm\_container\_app\_agent\_job\_name](#output\_azurerm\_container\_app\_agent\_job\_name) | n/a |
| <a name="output_azurerm_container_app_environment_name"></a> [azurerm\_container\_app\_environment\_name](#output\_azurerm\_container\_app\_environment\_name) | n/a |
| <a name="output_azurerm_container_app_placeholder_job_name"></a> [azurerm\_container\_app\_placeholder\_job\_name](#output\_azurerm\_container\_app\_placeholder\_job\_name) | n/a |
| <a name="output_azurerm_key_vault_id"></a> [azurerm\_key\_vault\_id](#output\_azurerm\_key\_vault\_id) | n/a |
| <a name="output_azurerm_key_vault_name"></a> [azurerm\_key\_vault\_name](#output\_azurerm\_key\_vault\_name) | n/a |
