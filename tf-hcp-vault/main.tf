terraform {
  required_version = "~> 1.0"

  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.43"
    }
  }
}

provider "hcp" {}

locals {
  supported_regions = {
    "aws"   = ["us-east-1", "us-east-2", "us-west-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "ap-northeast-1", "ap-southeast-1", "ap-southeast-2"]
    "azure" = ["westus2", "eastus", "centralus", "eastus2", "westeurope", "northeurope", "francecentral", "uksouth"]
  }

  region_short = replace(var.region, "-", "")
}

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

resource "hcp_vault_cluster" "this" {
  hvn_id          = hcp_hvn.vault.hvn_id
  cluster_id      = "${var.prefix}-vault-${var.cloud_provider}-${local.region_short}"
  public_endpoint = true
  tier            = var.vault_tier
}

resource "hcp_vault_cluster_admin_token" "admin" {
  cluster_id = hcp_vault_cluster.this.cluster_id
}
