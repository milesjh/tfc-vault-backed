variable "tfc_organization" {
  type        = string
  description = "The TFC organization to set up."
  default     = "milesjh-sandbox"
}

variable "workspace_names" {
    type = list
    description = "List of TFC Workspace Names to create"
    default = [
        "tf-hcp-vault", 
        "tf-hcp-vault-configs", 
        "vault-backed-aws", 
        "vault-backed-azure"
        ]
}