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

data "http" "host_ip" {
  url = "https://ipv4.icanhazip.com/"
}

module "github_container_apps_runner" {
  depends_on = [azurerm_resource_group.example]
  source     = "../../modules/github_runner_container_app_jobs"

  app_id     = "1234567"
  app_key    = base64encode(var.key)
  install_id = "1234567"
  owner      = "Altinn"
  repos = [
    "terraform-azurerm-altinn-modules"
  ]

  resource_prefix          = random_string.name.result
  infrastructure_subnet_id = azurerm_subnet.example.id
  resource_group_name      = azurerm_resource_group.example.name
  kv_ip_rules = [
    chomp(data.http.host_ip.response_body)
  ]
  additional_tags = {
    key = "value"
  }

  runner_cpu              = "0.75"
  runner_memory           = "1.5Gi"
  runner_image            = "ghcr.io/altinn/altinn-platform/gh-runner:v0.0.1"
  runner_max_running_jobs = "18"
  runner_labels           = "terraform,demo,azure,runner"
}

variable "key" {
  type        = string
  sensitive   = true
  description = "Github App Key"
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
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "http" {
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
  value = module.github_container_apps_runner.azurerm_container_app_environment_name
}

output "runner_job_names" {
  value = module.github_container_apps_runner.azurerm_container_app_runner_job_names
}
