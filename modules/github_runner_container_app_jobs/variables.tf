#######################################
# Azure resources specific variables  #
#######################################
variable "resource_group_name" {
  type = string
  description = "Name of the resource group that the resources should be placed in. Check for naming conflicts."
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resources"
}

variable "runner_ip" {
  default     = ""
  type        = string
  description = "IP of the runner setting up the infrastructure. This needs to be granted before updates with terraform is executed, this is just to ensure that it will not always have a change in the infrastructure"
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "The subnet_id where the container app jobs are running. The Subnet must have a /21 or larger address space."
}

variable "additional_tags" {
  type =map(string)
  description = "Additional tags that should be added to all resources. Concated with the default tags"
  default = {}
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
  default     = "Altinn"
  description = "Github owner/organization to add the runner to"
}

variable "repo" {
  type        = string
  description = "Github repo to add the runner to"
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