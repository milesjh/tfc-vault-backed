terraform {
  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }

    vault = {
      version = "~> 3.2"
      source  = "hashicorp/vault"
    }
  }
}
