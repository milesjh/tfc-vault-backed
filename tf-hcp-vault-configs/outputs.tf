output "vault_jwt_role" {
  description = "The Vault role for the JWT/OIDC auth backend."
  value       = module.jwt_auth.vault_role_jwt_auth
}

output "vault_target_iam_role_arn" {
  description = "The AWS IAM role ARN for the Vault assume role credential type."
  value       = module.aws_secrets.vault_target_iam_role_arn
}

output "vault_role_iam_user_credential_type" {
  value       = module.aws_secrets.vault_role_iam_user_credential_type
  description = "The Vault role for AWS `iam_user` credential type."
}

output "vault_role_assumed_role_credential_type" {
  value       = module.aws_secrets.vault_role_assumed_role_credential_type
  description = "The Vault role for AWS `assumed_role` credential type."
}

output "vault_role_federation_token_credential_type" {
  value       = module.aws_secrets.vault_role_federation_token_credential_type
  description = "The Vault role for AWS `federation_token` credential type."
}

# output "vault_role_gcp_viewer" {
#   description = "The Vault roleset for Google Cloud viewer access."
#   value       = module.google_secrets[0].vault_role_gcp_viewer
# }

# output "vault_role_gcp_editor" {
#   description = "The Vault roleset for Google Cloud editor access."
#   value       = module.google_secrets[0].vault_role_gcp_editor
# }
