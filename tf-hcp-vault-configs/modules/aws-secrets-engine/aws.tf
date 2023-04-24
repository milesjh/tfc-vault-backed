locals {
  my_email = var.email_address == "" ? split("/", data.aws_caller_identity.current.arn)[2] : var.email_address
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Vault Mount AWS Config Setup

# data "aws_iam_policy" "vault_aws_mount_demo_user_permissions" {
#   name = "DemoUser"
# }

resource "aws_iam_policy" "vault_aws_mount_demo_user_permissions" {
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
          "iam:RemoveUserFromGroup"
        ],
        "Resource" : ["arn:aws:iam::${var.aws_account_id}:user/vault-*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachUserPolicy",
          "iam:CreateUser",
          "iam:DeleteUserPolicy",
          "iam:DetachUserPolicy",
          "iam:PutUserPolicy"
        ],
        "Resource" : ["arn:aws:iam::${var.aws_account_id}:user/vault-*"],
        "Condition" : {
          "StringEquals" : {
            "iam:PermissionsBoundary" : [
              "arn:aws:iam::${var.aws_account_id}:policy/PolicyName"
            ]
          }
        }
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

data "aws_iam_policy_document" "vault_dynamic_iam_user_policy" {
  statement {
    sid       = "VaultDemoUserDescribeEC2Regions"
    actions   = ["ec2:DescribeRegions", "ec2:DescribeInstances"]
    resources = ["*"]
  }
}

# data "aws_iam_policy_document" "vault_dynamic_iam_role_policy" {
#   statement {
#     sid       = "VaultDemoRoleDescribeEC2Regions"
#     actions   = ["ec2:DescribeRegions", "ec2:DescribeInstances"]
#     # resources = ["*"]
#   }
# }

# # data "aws_iam_role" "vault_target_iam_role" {
# #   name = "vault-assumed-role-credentials-demo"
# # }

# resource "aws_iam_role" "vault_target_iam_role" {
#   name               = "vault-assumed-role-credentials-demo"
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.vault_dynamic_iam_role_policy.json
# }
