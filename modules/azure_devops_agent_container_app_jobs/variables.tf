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
  description = "Additional tags that should be added to all resources. Concated with the default tags"
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
