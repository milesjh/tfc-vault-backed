output "vault_jwt_role" {
  description = "The Vault role for the JWT/OIDC auth backend."
  value       = module.jwt_auth.vault_role_jwt_auth
}

output "vault_role_iam_user_credential_type" {
  value       = module.aws_secrets.vault_role_iam_user_credential_type
  description = "The Vault role for AWS `iam_user` credential type."
}

# output "vault_role_federation_token_credential_type" {
#   value       = module.aws_secrets.vault_role_federation_token_credential_type
#   description = "The Vault role for AWS `federation_token` credential type."
# }
