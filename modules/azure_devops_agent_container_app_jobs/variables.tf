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

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags that should be added to all resources. Concatenated with the default tags"
  default     = {}
}

#######################################
# Github tied variables               #
#######################################
variable "azp_token" {
  sensitive   = true
  type        = string
  description = "Base64 encoded Azure Devops PAT"
}

variable "azp_org_url" {
  sensitive   = true
  type        = string
  description = "URL for your Azure DevOps organization"
}

#######################################
# Runner tied variables               #
#######################################

variable "agent_image" {
  type        = string
  default     = "ghcr.io/altinn/altinn-platform/azure-devops-agent:v1.0.0"
  description = "Docker image to run when a job is scheduled"
}

variable "agent_cpu" {
  type        = string
  default     = "0.5"
  description = "CPU allocated to a runner"
}

variable "agent_memory" {
  type        = string
  default     = "1Gi"
  description = "Memory allocated to a runner"
}

variable "agent_pool_name" {
  type        = string
  description = "Name of the agent pool in azure devops"
}

variable "agent_max_running_jobs" {
  type        = string
  default     = "20"
  description = "Maximum number of jobs to run at one time"
}

variable "agent_replica_timeout" {
  default     = 7200
  type        = number
  description = "The maximum number of seconds a agent replica is allowed to run"
}

#######################################
# Container environment variables     #
#######################################

variable "agent_env_variables" {
  type        = map(string)
  default     = {}
  description = "Additional plain text environment variables for the agent container. Map key is the environment variable name, map value is its value. AZP_URL, AZP_TOKEN and AZP_POOL are set by the module and can not be overridden."

  validation {
    condition = alltrue([
      for name in keys(var.agent_env_variables) : can(regex("^[A-Za-z][A-Za-z0-9_]*$", name))
    ])
    error_message = "Environment variable names must start with a letter and consist of only letters, digits and underscores."
  }

  validation {
    condition     = length(setintersection(keys(var.agent_env_variables), ["AZP_URL", "AZP_TOKEN", "AZP_POOL"])) == 0
    error_message = "AZP_URL, AZP_TOKEN and AZP_POOL are set by the module and can not be set through agent_env_variables."
  }
}

variable "agent_env_secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Additional secret environment variables for the agent container. Map key is the environment variable name, map value is the secret value. The module stores each value as a secret in the key vault it creates and mounts it on the agent job. AZP_URL, AZP_TOKEN and AZP_POOL are set by the module and can not be overridden."

  validation {
    condition = alltrue([
      for name in keys(var.agent_env_secrets) : can(regex("^[A-Za-z][A-Za-z0-9_]*$", name))
    ])
    error_message = "Environment variable names must start with a letter and consist of only letters, digits and underscores."
  }

  validation {
    condition     = length(setintersection(keys(var.agent_env_secrets), ["AZP_URL", "AZP_TOKEN", "AZP_POOL"])) == 0
    error_message = "AZP_URL, AZP_TOKEN and AZP_POOL are set by the module and can not be set through agent_env_secrets."
  }

  validation {
    condition = length(distinct([
      for name in keys(var.agent_env_secrets) : lower(replace(name, "_", "-"))
    ])) == length(var.agent_env_secrets)
    error_message = "Environment variable names in agent_env_secrets must be unique after being lower cased with underscores replaced by dashes, since that is used as the container app secret name."
  }

  validation {
    condition = length(setintersection([
      for name in keys(var.agent_env_secrets) : lower(replace(name, "_", "-"))
    ], ["azp-token", "azp-org-url"])) == 0
    error_message = "The container app secret names azp-token and azp-org-url are reserved by the module."
  }

  validation {
    condition = alltrue([
      for name in keys(var.agent_env_secrets) : length(name) <= 100
    ])
    error_message = "Environment variable names in agent_env_secrets must be 100 characters or less, since the name is prefixed with resource_prefix to form the key vault secret name."
  }
}
