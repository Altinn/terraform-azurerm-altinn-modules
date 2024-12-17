resource "azurerm_container_app_environment" "agent_env" {
  name                     = "${var.resource_prefix}-${random_string.name.result}-env"
  location                 = data.azurerm_resource_group.agent_rg.location
  resource_group_name      = data.azurerm_resource_group.agent_rg.name
  infrastructure_subnet_id = var.infrastructure_subnet_id
  tags                     = local.all_tags
}


resource "azurerm_container_app_job" "placeholder_agent" {
  name                         = "${var.resource_prefix}-${random_string.name.result}-pha"
  location                     = data.azurerm_resource_group.agent_rg.location
  resource_group_name          = data.azurerm_resource_group.agent_rg.name
  container_app_environment_id = azurerm_container_app_environment.agent_env.id
  replica_timeout_in_seconds   = 1800
  tags                         = local.all_tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agent_managed_identity.id]
  }
  secret {
    name                = "azp-token"
    key_vault_secret_id = azurerm_key_vault_secret.azp_token.versionless_id
    identity            = azurerm_user_assigned_identity.agent_managed_identity.id
  }
  secret {
    name                = "azp-org-url"
    key_vault_secret_id = azurerm_key_vault_secret.azp_org_url.versionless_id
    identity            = azurerm_user_assigned_identity.agent_managed_identity.id
  }
  template {
    container {
      image  = var.agent_image
      cpu    = "0.5"
      memory = "1Gi"
      name   = "runner"
      env {
        name        = "AZP_URL"
        secret_name = "azp-org-url"
      }
      env {
        name        = "AZP_TOKEN"
        secret_name = "azp-token"
      }
      env {
        name  = "AZP_POOL"
        value = var.agent_pool_name
      }
      env {
        name  = "AZP_PLACEHOLDER"
        value = "1"
      }
      env {
        name  = "AZP_AGENT_NAME"
        value = "placeholder-agent"
      }
    }
  }

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }
}

resource "azurerm_container_app_job" "agent" {
  depends_on                   = [azurerm_container_app_job.placeholder_agent]
  name                         = "${var.resource_prefix}-${random_string.name.result}-agent"
  location                     = data.azurerm_resource_group.agent_rg.location
  resource_group_name          = data.azurerm_resource_group.agent_rg.name
  container_app_environment_id = azurerm_container_app_environment.agent_env.id
  replica_timeout_in_seconds   = 1800
  tags                         = local.all_tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agent_managed_identity.id]
  }
  secret {
    name                = "azp-token"
    key_vault_secret_id = azurerm_key_vault_secret.azp_token.versionless_id
    identity            = azurerm_user_assigned_identity.agent_managed_identity.id
  }
  secret {
    name                = "azp-org-url"
    key_vault_secret_id = azurerm_key_vault_secret.azp_org_url.versionless_id
    identity            = azurerm_user_assigned_identity.agent_managed_identity.id
  }
  template {
    container {
      image  = var.agent_image
      cpu    = var.agent_cpu
      memory = var.agent_memory
      name   = "runner"
      env {
        name        = "AZP_URL"
        secret_name = "azp-org-url"
      }
      env {
        name        = "AZP_TOKEN"
        secret_name = "azp-token"
      }
      env {
        name  = "AZP_POOL"
        value = var.agent_pool_name
      }
    }
  }

  event_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
    scale {
      min_executions              = 0
      max_executions              = var.agent_max_running_jobs
      polling_interval_in_seconds = 20
      rules {
        name             = "azure-pipelines-scaler"
        custom_rule_type = "azure-pipelines"
        metadata = {
          poolName                   = var.agent_pool_name
          targetPipelinesQueueLength = 1
        }
        authentication {
          trigger_parameter = "personalAccessToken"
          secret_name       = "azp-token"
        }
        authentication {
          trigger_parameter = "organizationURL"
          secret_name       = "azp-org-url"
        }
      }
    }
  }
}