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