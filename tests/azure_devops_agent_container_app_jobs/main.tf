data "azurerm_client_config" "current" {}

resource "random_string" "name" {
  length  = 6
  upper   = false
  numeric = false
  special = false
}

resource "azurerm_resource_group" "example" {
  name     = random_string.name.result
  location = "Norway East"
}

resource "azurerm_virtual_network" "example" {
  name                = "${random_string.name.result}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "${random_string.name.result}-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/21"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

module "azure_devops_container-apps-agent" {
  depends_on = [azurerm_resource_group.example]
  source     = "../../modules/azure_devops_agent_container_app_jobs"

  azp_org_url = "https://dev.azure.com/example"
  azp_token   = base64encode(var.pat)

  resource_prefix          = random_string.name.result
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name      = azurerm_resource_group.example.name
  kv_ip_rules = [
    "8.8.8.8"
  ]
  additional_tags = {
    key = "value"
  }

  agent_pool_name        = "example-azure-agent-pool"
  agent_cpu              = "0.75"
  agent_memory           = "1.5Gi"
  agent_image            = "ghcr.io/altinn/altinn-platform/azure-devops-agent:v1.0.0"
  agent_max_running_jobs = "18"
}

variable "pat" {
  type        = string
  sensitive   = true
  description = "Azure Devops PAT"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
  }
}

provider "azurerm" {
  features {}
}

output "resource_group_name" {
  value = azurerm_resource_group.example.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.example.name
}

output "subnet_name" {
  value = azurerm_subnet.example.name
}

output "environment_name" {
  value = module.azure_devops_container-apps-agent.azurerm_container_app_environment_name
}

output "placeholder_job_name" {
  value = module.azure_devops_container-apps-agent.azurerm_container_app_placeholder_job_name
}

output "agent_job_name" {
  value = module.azure_devops_container-apps-agent.azurerm_container_app_agent_job_name
}

output "key_vault_name" {
  value = module.azure_devops_container-apps-agent.azurerm_key_vault_name
}