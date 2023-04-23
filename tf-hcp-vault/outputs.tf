output "hvn_id" {
  value       = hcp_hvn.vault.id
  description = "ID of the HVN."
}

output "vault_public_endpoint_url" {
  value       = hcp_vault_cluster.this.vault_public_endpoint_url
  description = "Public endpoint of the HCP Vault cluster."
}

output "vault_admin_token" {
  value       = hcp_vault_cluster_admin_token.admin.token
  description = "Admin token for the HCP Vault cluster."
  sensitive   = true
}
