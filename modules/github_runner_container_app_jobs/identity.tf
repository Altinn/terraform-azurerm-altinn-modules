resource "azurerm_user_assigned_identity" "acaghr_managed_identity" {
  location            = data.azurerm_resource_group.acaghr_rg.location
  name                = "${var.resource_prefix}-acaghr-01"
  resource_group_name = data.azurerm_resource_group.acaghr_rg.name
}