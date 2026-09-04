resource "azurerm_container_app_environment" "acaghr_env" {
  name                           = "${var.resource_prefix}-${random_string.name.result}-acaghr"
  location                       = data.azurerm_resource_group.acaghr_rg.location
  resource_group_name            = data.azurerm_resource_group.acaghr_rg.name
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  # The provider rejects public_network_access = "Enabled" together with internal
  # load balancing mode. Left unset otherwise, so Azure keeps picking the value.
  public_network_access = var.internal_load_balancer_enabled ? "Disabled" : null
  tags                  = local.all_tags

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}


resource "azurerm_container_app_job" "acaghr_app_job" {
  for_each                     = var.repos
  name                         = "${var.resource_prefix}-${random_string.name.result}-${random_string.job_name[each.value].result}-acaghr"
  location                     = data.azurerm_resource_group.acaghr_rg.location
  resource_group_name          = data.azurerm_resource_group.acaghr_rg.name
  container_app_environment_id = azurerm_container_app_environment.acaghr_env.id
  replica_timeout_in_seconds   = var.runner_replica_timeout
  workload_profile_name        = "Consumption"
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
        value = var.owner
      }
      env {
        name  = "REPO_NAME"
        value = each.value
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
          owner          = var.owner
          repos          = each.value
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
