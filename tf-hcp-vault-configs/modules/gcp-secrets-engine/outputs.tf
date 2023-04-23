output "vault_role_gcp_viewer" {
  description = "The Vault roleset for Google Cloud viewer access."
  value       = vault_gcp_secret_roleset.roleset_viewer.roleset
}

output "vault_role_gcp_editor" {
  description = "The Vault roleset for Google Cloud editor access."
  value       = vault_gcp_secret_roleset.roleset_editor.roleset
}
