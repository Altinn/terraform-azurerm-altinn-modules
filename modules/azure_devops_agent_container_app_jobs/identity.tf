resource "azurerm_user_assigned_identity" "agent_managed_identity" {
  location            = data.azurerm_resource_group.agent_rg.location
  name                = "${var.resource_prefix}-${random_string.name.result}-agent"
  resource_group_name = data.azurerm_resource_group.agent_rg.name
  tags                = local.all_tags

  # costcenter and solution are added by Azure Policy. Ignore them so plans do not
  # remove them on every run.
  lifecycle {
    ignore_changes = [tags["costcenter"], tags["solution"]]
  }
}