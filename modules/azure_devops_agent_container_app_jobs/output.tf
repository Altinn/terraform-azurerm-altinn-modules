output "azurerm_container_app_placeholder_job_name" {
  value = azurerm_container_app_job.placeholder_agent.name
}

output "azurerm_container_app_agent_job_name" {
  value = azurerm_container_app_job.agent.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.agent_vault.id
}

output "azurerm_key_vault_name" {
  value = azurerm_key_vault.agent_vault.name
}

output "azurerm_container_app_environment_name" {
  value = azurerm_container_app_environment.agent_env.name
}