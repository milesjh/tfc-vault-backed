variable "aws_region" {
  type        = string
  description = "The region to use for AWS components."
  default     = "us-east-1"
}

variable "tfc_organization" {
  type        = string
  description = "The TFC organization to set up."
  default     = "dbarr-org"
}

variable "tfc_vault_role" {
  type        = string
  description = "The Vault role used for JWT auth from TFC."
  default     = "tfc-role"
}

variable "google_project_id" {
  type        = string
  description = "ID of the Google Cloud project."
  default     = null
}
