output "vault_azure_role" {
  value       = vault_azure_secret_backend_role.role1.role
  description = "The Vault role for Azure."
}