
locals {
  additional_ips = [for ip in var.kv_ip_rules : "${ip}/32"]
  ip_rules       = concat(local.additional_ips, ["${chomp(data.http.host_ip.response_body)}/32"])
  default_tags = {
    module = "altinn/altinn-modules/altinn_azure_devops_agent_container_app_jobs"
  }
  all_tags = merge(var.additional_tags, local.default_tags)
}

data "azurerm_resource_group" "agent_rg" {
  name = var.resource_group_name
}

data "http" "host_ip" {
  url = "https://ipv4.icanhazip.com/"
}

resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}