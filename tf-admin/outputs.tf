output "aws_workspace_id" {
  value       = tfe_workspace.main["vault-backed-aws"].id
  description = "ID of the Vault-backed AWS workspace."
}

output "azure_workspace_id" {
  value       = tfe_workspace.main["vault-backed-azure"].id
  description = "ID of the Vault-backed Azure workspace."
}

output "vault_workspace_id" {
  value       = tfe_workspace.main["tf-hcp-vault"].id
  description = "ID of the HCP Vault Cluster workspace."
}

output "vault_configs_workspace_id" {
  value       = tfe_workspace.main["tf-hcp-vault-configs"].id
  description = "ID of the HCP Vault Cluster Configs workspace."
}