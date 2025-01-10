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
}
```

Resources will inherit location from resource group

Hosts IP will automatically be added to the allow list in the firewall. Remember to remove it from the list if desirable.

