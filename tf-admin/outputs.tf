output "aws_workspace_id" {
  value       = tfe_workspace.main["vault-backed-aws"].id
  description = "ID of the Vault-backed AWS workspace."
}

output "azure_workspace_id" {
  value       = tfe_workspace.main["vault-backed-azure"].id
  description = "ID of the Vault-backed Azure workspace."
}