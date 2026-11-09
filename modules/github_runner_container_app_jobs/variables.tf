#######################################
# Azure resources specific variables  #
#######################################
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group that the resources should be placed in. Check for naming conflicts."
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resources"
  validation {
    condition     = length(var.resource_prefix) < 12 && var.resource_prefix == lower(var.resource_prefix)
    error_message = "resource_prefix must be 11 chars or less and consist of only lower case alphanumerical characters."
  }
}

variable "kv_ip_rules" {
  default     = []
  type        = set(string)
  description = "IPs that will be allowed to access the KV holding the secrets needed by the environment"
  validation {
    condition = alltrue([
      for ip in var.kv_ip_rules : can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
    ])
    error_message = "Invalid IP address provided in kv_ip_rules"
  }
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "The subnet_id where the container app jobs are running. The Subnet must have a /21 or larger address space."
}

variable "internal_load_balancer_enabled" {
  type        = bool
  default     = false
  description = "Run the container app environment in internal load balancing mode, so that it reserves an IP in infrastructure_subnet_id instead of a public one. The runner jobs only make outbound connections, so they do not need a public endpoint. Public network access on the environment is disabled in this mode, as required by the provider. Changing this forces the container app environment, and every job in it, to be recreated."
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags that should be added to all resources. Concated with the default tags"
  default     = {}
}

#######################################
# Github tied variables               #
#######################################
variable "app_key" {
  sensitive   = true
  type        = string
  description = "Base64 encoded Github app private key"
}

variable "app_id" {
  sensitive   = true
  type        = string
  description = "Github App Id"
}

variable "install_id" {
  sensitive   = true
  type        = string
  description = "Github Installation Id"
}

variable "owner" {
  type        = string
  description = "Github owner or organization"

}

variable "repos" {
  type        = set(string)
  description = "Set of repos there should be created a job for running actiosn. Each owner/repo will get it's own azure container app job in the environsment"
}

#######################################
# Runner tied variables               #
#######################################

variable "runner_image" {
  type        = string
  default     = "ghcr.io/Altinn/altinn-platform/gh-runner:latest"
  description = "Docker image to run when a job is scheduled"
}

variable "runner_cpu" {
  type        = string
  default     = "0.5"
  description = "CPU allocated to a runner"
}

variable "runner_memory" {
  type        = string
  default     = "1Gi"
  description = "Memory allocated to a runner"
}

variable "runner_max_running_jobs" {
  type        = string
  default     = "20"
  description = "Maximum number of jobs to run at one time"
}

variable "runner_labels" {
  default     = "default"
  type        = string
  description = "Additional labels to add to the runner"
}

variable "runner_replica_timeout" {
  default     = 7200
  type        = number
  description = "The maximum number of seconds a runner replica is allowed to run"
}

#######################################
# Scaler tied variables               #
#######################################

variable "polling_interval_in_seconds" {
  type        = number
  default     = 20
  description = "How often (in seconds) the KEDA github-runner scaler polls the GitHub API for queued jobs. Each poll costs at least 2 API calls per repo against the GitHub App installation rate limit."
  validation {
    condition     = var.polling_interval_in_seconds >= 5 && var.polling_interval_in_seconds <= 300
    error_message = "polling_interval_in_seconds must be between 5 and 300."
  }
}

variable "scaler_enable_etags" {
  type        = bool
  default     = false
  description = "Enable conditional requests (ETags) in the KEDA github-runner scaler. Unchanged responses (HTTP 304) do not count against the GitHub API rate limit. When false the enableEtags key is not sent to the scaler at all."
}

#######################################
# Container registry tied variables   #
#######################################

variable "container_registry" {
  type = object({
    id                     = optional(string)
    create_role_assignment = optional(bool, true)
  })
  default     = null
  description = <<-EOT
    Pull runner_image from a private Azure Container Registry with the job's managed identity. The registry server and repository are taken from runner_image. Leave null to pull anonymously (for example from ghcr.io).
    id: resource id of the registry. Required when create_role_assignment is true.
    create_role_assignment: grant the identity "Container Registry Repository Reader" on the registry, limited with an ABAC condition to the runner_image repository. The registry must use ABAC repository permissions, and the deploying principal must be allowed to create role assignments on it. Set to false to grant access outside the module, using the identity_principal_id output.
  EOT
  validation {
    condition     = var.container_registry == null || !try(var.container_registry.create_role_assignment, true) || try(var.container_registry.id, null) != null
    error_message = "container_registry.id is required when container_registry.create_role_assignment is true."
  }
  validation {
    condition     = var.container_registry == null || can(regex("^[^/]+\\.[^/]+/[^:@]+", var.runner_image))
    error_message = "runner_image must include the registry host (for example myacr.azurecr.io/repo/image:tag) when container_registry is set."
  }
}
