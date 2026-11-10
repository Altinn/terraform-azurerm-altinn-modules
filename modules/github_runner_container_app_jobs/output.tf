output "azurerm_container_app_runner_job_names" {
  value = {
    for name, job in azurerm_container_app_job.acaghr_app_job : name => job.name
  }
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.acaghr_vault.id
}

output "azurerm_key_vault_name" {
  value = azurerm_key_vault.acaghr_vault.name
}

output "azurerm_container_app_environment_name" {
  value = azurerm_container_app_environment.acaghr_env.name
}

output "identity_id" {
  description = "Resource id of the user assigned identity used by the runner jobs"
  value       = azurerm_user_assigned_identity.acaghr_managed_identity.id
}

output "identity_principal_id" {
  description = "Principal (object) id of the user assigned identity used by the runner jobs. Use it to grant registry access when container_registry.create_role_assignment is false"
  value       = azurerm_user_assigned_identity.acaghr_managed_identity.principal_id
}
