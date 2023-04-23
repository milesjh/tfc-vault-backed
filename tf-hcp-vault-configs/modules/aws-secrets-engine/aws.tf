locals {
  my_email = var.email_address == "" ? split("/", data.aws_caller_identity.current.arn)[2] : var.email_address
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Vault Mount AWS Config Setup

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy" "vault_mount_user" {
  user   = aws_iam_user.vault_mount_user.name
  policy = data.aws_iam_policy.demo_user_permissions_boundary.policy
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

data "aws_iam_role" "vault_target_iam_role" {
  name = "vault-assumed-role-credentials-demo"
}
