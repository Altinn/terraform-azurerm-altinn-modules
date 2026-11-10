# By default every managed identity on a container app job is available to the
# code running in its containers, through IDENTITY_ENDPOINT. The runner identity
# can read the GitHub App private key from the key vault, so any workflow running
# on a runner could fetch the key and act as the GitHub App.
#
# The platform only needs the identity for the Key Vault secret reference (and
# image pull from a private registry), so set its lifecycle to "None": usable by
# the platform, not available to code in the containers.
#
# azurerm does not expose identitySettings on container app jobs, so it is set
# with azapi after the job is created.
resource "azapi_update_resource" "acaghr_identity_settings" {
  for_each    = azurerm_container_app_job.acaghr_app_job
  type        = "Microsoft.App/jobs@2025-07-01"
  resource_id = each.value.id

  body = {
    properties = {
      configuration = {
        identitySettings = [
          {
            # Must match the id in the job's identity block exactly (Azure
            # compares it case-sensitively and silently drops a mismatch).
            identity  = azurerm_user_assigned_identity.acaghr_managed_identity.id
            lifecycle = "None"
          }
        ]
      }
    }
  }

  lifecycle {
    # azurerm does not know about identitySettings. Re-apply the setting
    # whenever azurerm changes the job, in case the update drops it.
    replace_triggered_by = [azurerm_container_app_job.acaghr_app_job[each.key]]

    # Azure returns the identity id with "resourcegroups" in lower case, which
    # would show as a change on every plan. A new identity also changes the
    # job, which re-creates this resource through replace_triggered_by, so
    # ignoring the field here does not hide a real change. Drift in lifecycle
    # is still detected.
    ignore_changes = [body.properties.configuration.identitySettings[0].identity]
  }
}
