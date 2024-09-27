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
  service_endpoints = ["Microsoft.KeyVault"]
}

module "hello-modules_container-apps-gh-runners" {
  source     = "Altinn/altinn-modules/azurerm//modules/github_runner_container_app_jobs"
  version    = "0.0.1"
  app_id     = "<appid>"
  install_id = "<installid>"
  app_key    = "<secret-app-key>"
  owner      = "Altinn"
  repo       = "terraform-azurerm-altinn-modules"
  runner_ip  = <ip-of-machine-running-terraform>
  resource_prefix= example
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name = azurerm_resource_group.example.name
}
```

Resources will inherit location from resource group

