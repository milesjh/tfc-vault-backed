output "vault_role_iam_user_credential_type" {
  value       = vault_aws_secret_backend_role.vault_role_iam_user_credential_type.name
  description = "The Vault role for AWS `iam_user` credential type."
}

output "vault_role_federation_token_credential_type" {
  value       = vault_aws_secret_backend_role.vault_role_federation_token_credential_type.name
  description = "The Vault role for AWS `federation_token` credential type."
}
