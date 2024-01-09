variable "tfc_organization" {
  type        = string
  description = "The TFC organization to set up."
  default     = "milesjh-sandbox"
}

variable "workspace_names" {
  type        = set(string)
  description = "List of TFC Workspace Names to create"
  default = [
    "tf-hcp-vault",
    "tf-hcp-vault-configs",
    "vault-backed-aws",
    "vault-backed-azure"
  ]
}

variable "tf-hcp-vault-vars" {
  type        = map(any)
  description = "Variables to add to tf-hcp-vault workspace"
  default = {
    cloud_provider = "azure"
    region         = "centralus"
    prefix         = "milesjh"
    vault_tier     = "STARTER_SMALL"
  }
}

variable "tf-hcp-vault-configs-vars" {
  type        = map(any)
  description = "Variables to add to tf-hcp-vault-configs workspace"
  default = {
    aws_region        = "us-east-2"
    tfc_organization  = "milesjh-sandbox"
    tfc_vault_role    = "tfc-role"
  }
}