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

