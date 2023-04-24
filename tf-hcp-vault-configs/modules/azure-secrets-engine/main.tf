terraform {
  required_providers {
    azurerm = {
      version = "~> 3.0"
      source  = "hashicorp/azurerm"
    }

    vault = {
      version = "~> 3.2"
      source  = "hashicorp/vault"
    }
  }
}
