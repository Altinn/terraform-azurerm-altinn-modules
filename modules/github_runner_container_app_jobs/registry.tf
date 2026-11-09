locals {
  # Registry host and repository are taken from runner_image, so the job pulls
  # from, and the identity is granted access to, exactly the image that runs.
  # Example: myacr.azurecr.io/altinn-platform/gh-runner:v1.2.3
  #   -> server "myacr.azurecr.io", repository "altinn-platform/gh-runner"
  runner_image_parts      = try(regex("^([^/]+)/([^:@]+)", var.runner_image), [null, null])
  runner_image_server     = local.runner_image_parts[0]
  runner_image_repository = local.runner_image_parts[1]

  registry_identity_enabled = var.container_registry != null
  registry_role_assignment  = local.registry_identity_enabled && try(var.container_registry.create_role_assignment, false)
}

# Read access to the runner image repository only. Requires the registry to use
# the "RBAC Registry + ABAC Repository Permissions" role assignment mode.
resource "azurerm_role_assignment" "acaghr_registry_pull" {
  count                = local.registry_role_assignment ? 1 : 0
  scope                = var.container_registry.id
  role_definition_name = "Container Registry Repository Reader"
  principal_id         = azurerm_user_assigned_identity.acaghr_managed_identity.principal_id
  principal_type       = "ServicePrincipal"
  description          = "Pull ${local.runner_image_repository} for GitHub runners (${var.resource_prefix}-${random_string.name.result}-acaghr)"
  condition_version    = "2.0"
  condition            = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
      AND
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
     )
     OR
     (
      @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringEqualsIgnoreCase '${local.runner_image_repository}'
     )
    )
  EOT
}
