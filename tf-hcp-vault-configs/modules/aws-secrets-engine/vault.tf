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

# resource "vault_aws_secret_backend_role" "vault_role_federation_token_credential_type" {
#   backend         = vault_aws_secret_backend.vault_aws.path
#   credential_type = "federation_token"
#   name            = "vault-demo-federation-token"
#   policy_document = aws_iam_policy.vault_dynamic_iam_user_policy.policy
# }

# Create and Configure AWS Secrets Engine
#Create policy for AWS dynamic creds read
resource "vault_policy" "aws" {
  name   = "aws"
  policy = <<EOT
    path "aws/creds/vault-demo-iam-user"
    {
        capabilities = ["read"]
    }
    EOT
}
resource "vault_aws_secret_backend" "vault_aws" {
  access_key        = aws_iam_access_key.vault_aws_key.id
  secret_key        = aws_iam_access_key.vault_aws_key.secret
  description       = "Demo of the AWS secrets engine"
  region            = var.region
  username_template = "{{ if (eq .Type \"STS\") }}{{ printf \"vault-%s-%s-%s\" (.PolicyName) (unix_time) (random 20) | truncate 32 }}{{ else }}{{ printf \"vault-%s-%s-%s\" (.PolicyName) (unix_time) (random 20) | truncate 60 }}{{ end }}"
}

