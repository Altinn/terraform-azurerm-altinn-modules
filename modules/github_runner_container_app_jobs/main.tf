
locals {
  ip_rules = [for ip in var.var.kv_ip_rules : "${ip}/32"]
  default_tags = {
    module = "altinn/altinn-modules/altinn_github_runner_container_app_jobs"
  }
  all_tags = concat(var.additional_tags, default_tags)
}

data "azurerm_resource_group" "acaghr_rg" {
  name = var.resource_group_name
}

resource "random_string" "name" {
  length  = 6
  special = false
}