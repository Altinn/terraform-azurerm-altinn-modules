resource "azurerm_user_assigned_identity" "acaghr_managed_identity" {
  location            = data.azurerm_resource_group.acaghr_rg.location
  name                = "${var.resource_prefix}-${random_string.name}-acaghr"
  resource_group_name = data.azurerm_resource_group.acaghr_rg.name
  tags                = local.all_tags
}