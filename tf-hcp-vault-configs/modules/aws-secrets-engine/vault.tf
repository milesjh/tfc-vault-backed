resource "vault_aws_secret_backend" "vault_aws" {
  access_key        = aws_iam_access_key.vault_mount_user.id
  secret_key        = aws_iam_access_key.vault_mount_user.secret
  description       = "AWS secrets engine"
  region            = data.aws_region.current.name
  username_template = "{{ if (eq .Type \"STS\") }}{{ printf \"${aws_iam_user.vault_mount_user.name}-%s-%s\" (random 20) (unix_time) | truncate 32 }}{{ else }}{{ printf \"${aws_iam_user.vault_mount_user.name}-vault-%s-%s\" (unix_time) (random 20) | truncate 60 }}{{ end }}"
}

resource "vault_aws_secret_backend_role" "vault_role_iam_user_credential_type" {
  backend                  = vault_aws_secret_backend.vault_aws.path
  credential_type          = "iam_user"
  name                     = "vault-demo-iam-user"
  permissions_boundary_arn = aws_iam_policy.vault_aws_mount_demo_user_permissions.arn
  policy_document          = data.aws_iam_policy_document.vault_dynamic_iam_user_policy.json
}

resource "vault_aws_secret_backend_role" "vault_role_federation_token_credential_type" {
  backend         = vault_aws_secret_backend.vault_aws.path
  credential_type = "federation_token"
  name            = "vault-demo-federation-token"
  policy_document = data.aws_iam_policy_document.vault_dynamic_iam_user_policy.json
}

# resource "vault_aws_secret_backend_role" "vault_role_assumed_role_credential_type" {
#   backend         = vault_aws_secret_backend.vault_aws.path
#   credential_type = "assumed_role"
#   name            = "vault-demo-assumed-role"
#   role_arns       = [aws_iam_role.vault_target_iam_role.arn]
# }
