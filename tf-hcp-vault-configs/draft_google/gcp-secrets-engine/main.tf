terraform {
  required_providers {
    google = {
      version = "~> 4.0"
      source  = "hashicorp/google"
    }

    vault = {
      version = "~> 3.2"
      source  = "hashicorp/vault"
    }
  }
}
