terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  cloud {
    organization = "milesjh-sandbox"
    workspaces {
      name = "vault-backed-azure"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "vault" {}

data "azurerm_resource_group" "main" {
  name = var.rg_name
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name = "secret"
}

resource "azurerm_virtual_network" "main" {
  name                = "milesjh-sandbox-network"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  tags = data.vault_kv_secret_v2.example.data
  # {
  #   environment = "sandbox"
  # }
}