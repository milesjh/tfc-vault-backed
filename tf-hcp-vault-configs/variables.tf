variable "aws_region" {
  type        = string
  description = "The region to use for AWS components."
}

variable "tfc_organization" {
  type        = string
  description = "The TFC organization to set up."
}

variable "tfc_vault_role" {
  type        = string
  description = "The Vault role used for JWT auth from TFC."
  default     = "tfc-role"
}

variable "client_id" {
  type        = string
  description = "Azure static cred params for Vault Config"
}

variable "client_secret" {
  type        = string
  description = "Azure static cred params for Vault Config"
}

variable "subscription_id" {
  type        = string
  description = "Azure static cred params for Vault Config"
}

variable "tenant_id" {
  type        = string
  description = "Azure static cred params for Vault Config"
}

variable "rg_name" {
  type        = string
  description = "Azure static cred params for Vault Config"
}

variable "admin_username" {
  sensitive = true
}

variable "admin_password" {
  sensitive = true
}
