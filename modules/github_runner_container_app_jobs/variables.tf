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
