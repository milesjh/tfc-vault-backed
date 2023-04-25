resource "vault_aws_secret_backend" "vault_aws" {
  access_key        = aws_iam_access_key.vault_mount_user.id
  secret_key        = aws_iam_access_key.vault_mount_user.secret
  description       = "AWS secrets engine"
  region            = data.aws_region.current.name
}

resource "vault_aws_secret_backend_role" "vault_role_iam_user_credential_type" {
  backend                  = vault_aws_secret_backend.vault_aws.path
  credential_type          = "iam_user"
  name                     = "vault-demo-iam-user"
  policy_document          = aws_iam_policy.vault_dynamic_iam_user_policy.policy
}

resource "vault_aws_secret_backend_role" "vault_role_federation_token_credential_type" {
  backend         = vault_aws_secret_backend.vault_aws.path
  credential_type = "federation_token"
  name            = "vault-demo-federation-token"
  policy_document = aws_iam_policy.vault_dynamic_iam_user_policy.policy
}


