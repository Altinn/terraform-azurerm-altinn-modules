data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "acaghr_vault" {
  name                       = "${var.resource_prefix}${random_string.name}acaghr"
  location                   = data.azurerm_resource_group.acaghr_rg.location
  resource_group_name        = data.azurerm_resource_group.acaghr_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.all_tags


  network_acls {
    bypass         = "None"
    default_action = "Deny"
    virtual_network_subnet_ids = [
      azurerm_subnet.acaghr_subnet.id
    ]
    ip_rules = local.ip_rules
  }

  public_network_access_enabled = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.acaghr_managed_identity.tenant_id
    object_id = azurerm_user_assigned_identity.acaghr_managed_identity.principal_id
    secret_permissions = [
      "Get"
    ]
  }
}

resource "azurerm_key_vault_secret" "acaghr_app_key" {
  depends_on   = [azurerm_key_vault.acaghr_vault]
  name         = "${var.resource_prefix}-app-key"
  value        = base64decode(var.app_key)
  key_vault_id = azurerm_key_vault.acaghr_vault.id
}