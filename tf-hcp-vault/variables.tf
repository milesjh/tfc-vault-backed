variable "prefix" {
  type        = string
  description = "This prefix will be used to generate unique resource names."
}

variable "cloud_provider" {
  type        = string
  description = "Cloud provider where the HVN and Vault cluster will be located."

  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "The supported providers are 'aws' and 'azure'."
  }
}

# Supported AWS regions: https://developer.hashicorp.com/hcp/docs/hcp/supported-env/aws
# Supported Azure regions: https://developer.hashicorp.com/hcp/docs/hcp/supported-env/azure
variable "region" {
  type        = string
  description = "Region where the HVN and Vault cluster will be located."
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the HVN."
  default     = "172.25.16.0/20"

  validation {
    condition     = can(cidrhost(var.cidr_block, 32))
    error_message = "The CIDR block must be a valid IPv4 CIDR."
  }
}

variable "vault_tier" {
  type        = string
  description = "Sizing tier of the Vault cluster."
  default     = "dev"

  validation {
    condition     = contains(["dev", "starter_small", "standard_small", "standard_medium", "standard_large", "plus_small", "plus_medium", "plus_large"], var.vault_tier)
    error_message = "Invalid tier was specified."
  }
}
