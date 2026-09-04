terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=5.0.0, <6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
  }
}