terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.3"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.4.5"
    }
  }
}