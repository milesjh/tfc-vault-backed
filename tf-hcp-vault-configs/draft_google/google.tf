# terraform {
#   required_providers {
#     google = {
#       version = "~> 4.0"
#       source  = "hashicorp/google"
#     }
#   }
# }

# provider "google" {
#   project = var.google_project_id
#   region  = "global"
# }


# module "google_secrets" {
#   count      = var.google_project_id == null ? 0 : 1
#   source     = "./modules/gcp-secrets-engine"
#   project_id = var.google_project_id
# }

# resource "tfe_variable_set" "vault_backed_gcp" {
#   organization = var.tfc_organization
#   name         = "GCP Vault-Backed Dynamic Credentials"
#   description  = "Vault-backed dynamic credentials for Google Cloud provider using roleset/access_token."
# }

# resource "tfe_variable" "vault_backed_gcp" {
#   for_each = {
#     TFC_VAULT_PROVIDER_AUTH                  = "true"
#     TFC_VAULT_ADDR                           = data.tfe_outputs.vault_cluster.values.vault_public_endpoint_url
#     TFC_VAULT_NAMESPACE                      = "admin"
#     TFC_VAULT_RUN_ROLE                       = var.tfc_vault_role
#     TFC_VAULT_BACKED_GCP_AUTH                = "true"
#     TFC_VAULT_BACKED_GCP_AUTH_TYPE           = "roleset/access_token"
#     TFC_VAULT_BACKED_GCP_PLAN_VAULT_ROLESET  = module.google_secrets[0].vault_role_gcp_viewer
#     TFC_VAULT_BACKED_GCP_APPLY_VAULT_ROLESET = module.google_secrets[0].vault_role_gcp_editor
#   }

#   category        = "env"
#   key             = each.key
#   value           = each.value
#   variable_set_id = tfe_variable_set.vault_backed_gcp.id
# }

# data "tfe_project" "gcp" {
#   name         = "Google"
#   organization = var.tfc_organization
# }

# resource "tfe_project_variable_set" "vault_backed_gcp" {
#   variable_set_id = tfe_variable_set.vault_backed_gcp.id
#   project_id      = data.tfe_project.gcp.id
# }


# variable "google_project_id" {
#   type        = string
#   description = "ID of the Google Cloud project."
# }

# output "vault_role_gcp_viewer" {
#   description = "The Vault roleset for Google Cloud viewer access."
#   value       = module.google_secrets[0].vault_role_gcp_viewer
# }

# output "vault_role_gcp_editor" {
#   description = "The Vault roleset for Google Cloud editor access."
#   value       = module.google_secrets[0].vault_role_gcp_editor
# }