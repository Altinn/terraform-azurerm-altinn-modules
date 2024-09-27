
locals {
  ip_rules          = var.runner_ip != "" ? ["${var.runner_ip}/32"] : []
}

data "azurerm_resource_group" "acaghr_rg" {
  name     = var.resource_group_name
}

