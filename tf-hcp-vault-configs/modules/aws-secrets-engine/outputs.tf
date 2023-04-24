# output "vault_target_iam_role_arn" {
#   description = "The AWS IAM role ARN for the Vault assume role credential type."
#   value       = aws_iam_role.vault_target_iam_role.arn
# }

output "vault_role_iam_user_credential_type" {
  value       = vault_aws_secret_backend_role.vault_role_iam_user_credential_type.name
  description = "The Vault role for AWS `iam_user` credential type."
}

# output "vault_role_assumed_role_credential_type" {
#   value       = vault_aws_secret_backend_role.vault_role_assumed_role_credential_type.name
#   description = "The Vault role for AWS `assumed_role` credential type."
# }

output "vault_role_federation_token_credential_type" {
  value       = vault_aws_secret_backend_role.vault_role_federation_token_credential_type.name
  description = "The Vault role for AWS `federation_token` credential type."
}
