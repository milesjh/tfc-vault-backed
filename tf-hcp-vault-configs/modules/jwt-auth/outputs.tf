output "vault_role_jwt_auth" {
  description = "The Vault role for the JWT/OIDC auth backend."
  value       = vault_jwt_auth_backend_role.tfc_role.role_name
}
