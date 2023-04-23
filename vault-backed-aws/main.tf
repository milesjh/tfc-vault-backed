terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "milesjh-sandbox"
    workspaces {
      name = "vault-backed-aws-demo"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_regions" "available" {
  all_regions = false
}

data "aws_instances" "running" {
  instance_state_names = ["running", "stopped"]
}
