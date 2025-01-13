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
  source     = "Altinn/altinn-modules/azurerm//modules/github_runner_container_app_jobs"
  version    = "1.0.1" #See releases for latest version
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
}
```

Resources will inherit location from resource group

