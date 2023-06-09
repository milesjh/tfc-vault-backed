terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.2"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.43"
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
provider "hcp" {}

data "azurerm_resource_group" "main" {
  name = var.rg_name
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "secret"
}

data "hcp_packer_image" "myapp" {
  bucket_name    = "hcp-packer-myapp"
  channel = "latest"
  cloud_provider = "azure"
  region         = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "milesjh-sandbox-network"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "sandbox"
  }
  
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_D2_v5"
  admin_username      = data.vault_kv_secret_v2.example.data["admin_username"]
  admin_password      = data.vault_kv_secret_v2.example.data["admin_password"]
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  source_image_id = data.hcp_packer_image.myapp.cloud_image_id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}