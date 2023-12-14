locals {
  my_email = var.email_address == "" ? split("/", data.aws_caller_identity.current.arn)[2] : var.email_address
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Vault Mount AWS Config Setup

/* resource "aws_iam_policy" "vault_aws_mount_demo_user_permissions" {
  name        = "VaultAWSDemoUser"
  path        = "/"
  description = "Vault AWS Secrets Engine User Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:DeleteUser",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListGroupsForUser",
          "iam:ListUserPolicies",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",
          "iam:AttachUserPolicy",
          "iam:CreateUser",
          "iam:DeleteUserPolicy",
          "iam:DetachUserPolicy",
          "iam:PutUserPolicy"
        ],
        "Resource" : ["arn:aws:iam::${var.aws_account_id}:user/vault-*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "autoscaling:*",
          "iam:CreateServiceLinkedRole"
        ]
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = aws_iam_policy.vault_aws_mount_demo_user_permissions.arn
  force_destroy        = true
}

resource "aws_iam_user_policy" "vault_mount_user" {
  user   = aws_iam_user.vault_mount_user.name
  policy = aws_iam_policy.vault_aws_mount_demo_user_permissions.policy
  name   = "DemoUserInlinePolicy"
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

# Vault Mount AWS Role Setup

resource "aws_iam_policy" "vault_dynamic_iam_user_policy" {
  name        = "DynamicVaultUser-EC2"
  path        = "/"
  description = "EC2 User Policy to be used with Vault dynamic IAM Users"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "autoscaling:*",
          "iam:CreateServiceLinkedRole"
        ]
        "Resource" : "*"
      }
    ]
  })
} */


# Create IAM user and keys that Vault can use to connect to AWS to generate short lived credentials
resource "aws_iam_user" "vault_aws_user" {
  name          = "vault-aws-secrets-user"
  force_destroy = true
}

resource "aws_iam_policy" "vault_aws_policy" {
  name   = "vault-aws-secrets-user-policy"
  policy = data.aws_iam_policy_document.vault_aws_secrets_user_policy.json
}

resource "aws_iam_user_policy_attachment" "vault_aws_user" {
  user       = aws_iam_user.vault_aws_user.name
  policy_arn = aws_iam_policy.vault_aws_policy.arn
}

resource "aws_iam_access_key" "vault_aws_key" {
  user = aws_iam_user.vault_aws_user.name
}