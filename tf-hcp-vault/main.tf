terraform {
  required_version = "~> 1.0"

  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.78.0"
    }
  }
}

provider "hcp" {}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

locals {
  supported_regions = {
    "aws"   = ["us-east-1", "us-east-2", "us-west-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2"]
    "azure" = ["westus2", "eastus", "centralus", "eastus2", "westeurope", "northeurope", "francecentral", "uksouth"]
  }

  region_short = replace(var.region, "-", "")

  uid             = random_uuid.uuid.result
  short_uid       = format("%.10s", local.uid)

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "random_uuid" "uuid" {}

resource "hcp_hvn" "vault" {
  hvn_id         = "${var.prefix}-hvn-${var.cloud_provider}-${local.region_short}"
  cloud_provider = var.cloud_provider
  region         = var.region
  cidr_block     = var.cidr_block

  lifecycle {
    precondition {
      condition     = contains(local.supported_regions[var.cloud_provider], var.region)
      error_message = "${var.region} is not a supported region for HVNs in ${var.cloud_provider}"
    }
  }
}

resource "hcp_azure_peering_connection" "peering" {
  hvn_link                 = hcp_hvn.hvn.self_link
  peering_id               = "pcx-${local.short_uid}"
  peer_subscription_id     = local.subscription_id
  peer_tenant_id           = local.tenant_id
  peer_vnet_name           = azurerm_virtual_network.vnet.name
  peer_resource_group_name = azurerm_resource_group.rg.name
  peer_vnet_region         = var.region

  // Hub / Spoke networking config
  allow_forwarded_traffic = false
  use_remote_gateways     = true
}

// This data source is the same as the resource above, but waits for the connection
// to be Active before returning.
data "hcp_azure_peering_connection" "peering" {
  hvn_link              = hcp_hvn.hvn.self_link
  peering_id            = hcp_azure_peering_connection.peering.peering_id
  wait_for_active_state = true
}

// The route depends on the data source, rather than the resource, to ensure the
// peering is in an Active state.
resource "hcp_hvn_route" "route" {
  hvn_route_id     = "route-${local.short_uid}"
  hvn_link         = hcp_hvn.hvn.self_link
  destination_cidr = "192.168.0.0/16"
  target_link      = data.hcp_azure_peering_connection.peering.self_link

  // Hub / Spoke networking config
  azure_config {
    next_hop_type = "VIRTUAL_NETWORK_GATEWAY"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.short_uid}"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.short_uid}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [
    "10.0.101.0/24"
  ]
}

// ------------------------------------------------------------------------ //
//                            Gateway Config                                //
// ------------------------------------------------------------------------ //

resource "azurerm_subnet" "subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    "10.0.101.0/26"
  ]
}

resource "azurerm_public_ip" "ip" {
  name                = "ip-${local.short_uid}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "gateway-${local.short_uid}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  enable_bgp          = false // Explicit; defaults to false
  sku                 = "Basic"

  ip_configuration {
    name                          = "ipconf-${local.short_uid}"
    public_ip_address_id          = azurerm_public_ip.ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
  }
}


resource "hcp_vault_cluster" "this" {
  hvn_id          = hcp_hvn.vault.hvn_id
  cluster_id      = "${var.prefix}-vault-${var.cloud_provider}-${local.region_short}"
  public_endpoint = true
  tier            = var.vault_tier
}

resource "hcp_vault_cluster_admin_token" "admin" {
  cluster_id = hcp_vault_cluster.this.cluster_id
}