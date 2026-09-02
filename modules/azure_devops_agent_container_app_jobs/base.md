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

resource "azurerm_key_vault_secret" "extra" {
  name         = "example-extra-secret"
  value        = "not-a-real-secret"
  key_vault_id = module.hello-modules_container-apps-agent.azurerm_key_vault_id
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
    EXTRA_SECRET = azurerm_key_vault_secret.extra.versionless_id
  }
}
```

Resources will inherit location from resource group

Hosts IP will automatically be added to the allow list in the firewall. Remember to remove it from the list if desirable.

## Environment variables

`agent_env_variables` and `agent_env_secrets` add environment variables to the agent job. The
placeholder job is not affected. `AZP_URL`, `AZP_TOKEN` and `AZP_POOL` are set by the module and
can not be overridden through either input.

`agent_env_secrets` values must be versionless ids of secrets in the key vault created by this
module. Use the `azurerm_key_vault_id` output to create the secret, and always pass the resource
attribute (`azurerm_key_vault_secret.example.versionless_id`) rather than a hand built url string.
The attribute reference is what makes terraform create the secret before the agent job that reads
it; with a plain string the job can be created first and fail to resolve the reference.

Each environment variable name is lower cased with underscores replaced by dashes to form the
container app secret name, so `EXTRA_SECRET` is stored as the secret `extra-secret` on the job.

