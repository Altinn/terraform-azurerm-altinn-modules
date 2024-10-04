resource "azurerm_container_app_environment" "acaghr_env" {
  name                     = "${var.resource_prefix}-${random_string.name}-acaghr"
  location                 = data.azurerm_resource_group.acaghr_rg.location
  resource_group_name      = data.azurerm_resource_group.acaghr_rg.name
  infrastructure_subnet_id = var.infrastructure_subnet_id
  tags                     = local.all_tags
}


resource "azurerm_container_app_job" "acaghr_app_job" {
  for_each                     = { for index, repo in var.repos : "${repo.owner}/${repo.name}" => repo }
  name                         = "${var.resource_prefix}-${random_string.resource_name.result}-${random_string.job_name[each.key].result}-acaghr"
  location                     = data.azurerm_resource_group.acaghr_rg.location
  resource_group_name          = data.azurerm_resource_group.acaghr_rg.name
  container_app_environment_id = azurerm_container_app_environment.acaghr_env.id
  replica_timeout_in_seconds   = 1800
  tags                         = local.all_tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acaghr_managed_identity.id]
  }
  secret {
    name                = "app-key"
    key_vault_secret_id = azurerm_key_vault_secret.acaghr_app_key.versionless_id
    identity            = azurerm_user_assigned_identity.acaghr_managed_identity.id
  }
  template {
    container {
      image  = var.runner_image
      cpu    = var.runner_cpu
      memory = var.runner_memory
      name   = "runner"
      env {
        name  = "APP_ID"
        value = var.app_id
      }
      env {
        name        = "APP_PRIVATE_KEY"
        secret_name = "app-key"
      }
      env {
        name  = "ORG_NAME"
        value = each.value.owner
      }
      env {
        name  = "REPO_NAME"
        value = each.value.name
      }
      env {
        name  = "LABELS"
        value = var.runner_labels
      }
    }
  }

  event_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
    scale {
      min_executions              = 0
      max_executions              = var.runner_max_running_jobs
      polling_interval_in_seconds = 20
      rules {
        name             = "github-runner-scaler"
        custom_rule_type = "github-runner"
        metadata = {
          applicationID  = var.app_id
          installationID = var.install_id
          githubAPIURL   = "https://api.github.com"
          owner          = each.value.owner
          repos          = each.value.name
          runnerScope    = "repo"
          labels         = var.runner_labels
        }
        authentication {
          trigger_parameter = "appKey"
          secret_name       = "app-key"
        }
      }
    }
  }
}
