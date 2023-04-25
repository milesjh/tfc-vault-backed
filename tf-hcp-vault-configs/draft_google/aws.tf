
# resource "tfe_variable_set" "vault_backed_aws_role" {
#   organization = var.tfc_organization
#   name         = "AWS Vault-Backed Dynamic Credentials - Assumed Role"
#   description  = "Vault-backed dynamic credentials for AWS provider using assume_role."
# }

# # moved {
# #   from = tfe_variable_set.vault_backed_aws
# #   to   = tfe_variable_set.vault_backed_aws_role
# # }

# resource "tfe_variable" "vault_backed_aws_role" {
#   for_each = {
#     TFC_VAULT_PROVIDER_AUTH             = "true"
#     TFC_VAULT_ADDR                      = data.tfe_outputs.tf-hcp-vault.values.vault_public_endpoint_url
#     TFC_VAULT_NAMESPACE                 = "admin"
#     TFC_VAULT_RUN_ROLE                  = var.tfc_vault_role
#     TFC_VAULT_BACKED_AWS_AUTH           = "true"
#     TFC_VAULT_BACKED_AWS_AUTH_TYPE      = "assumed_role"
#     TFC_VAULT_BACKED_AWS_RUN_VAULT_ROLE = module.aws_secrets.vault_role_assumed_role_credential_type
#     TFC_VAULT_BACKED_AWS_RUN_ROLE_ARN   = module.aws_secrets.vault_target_iam_role_arn
#   }

#   category        = "env"
#   key             = each.key
#   value           = each.value
#   variable_set_id = tfe_variable_set.vault_backed_aws_role.id
# }



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

# output "vault_role_assumed_role_credential_type" {
#   value       = vault_aws_secret_backend_role.vault_role_assumed_role_credential_type.name
#   description = "The Vault role for AWS `assumed_role` credential type."
# }

# output "vault_target_iam_role_arn" {
#   description = "The AWS IAM role ARN for the Vault assume role credential type."
#   value       = aws_iam_role.vault_target_iam_role.arn
# }

# resource "vault_aws_secret_backend_role" "vault_role_assumed_role_credential_type" {
#   backend         = vault_aws_secret_backend.vault_aws.path
#   credential_type = "assumed_role"
#   name            = "vault-demo-assumed-role"
#   role_arns       = [aws_iam_role.vault_target_iam_role.arn]
# }

# output "vault_target_iam_role_arn" {
#   description = "The AWS IAM role ARN for the Vault assume role credential type."
#   value       = module.aws_secrets.vault_target_iam_role_arn
# }

# output "vault_role_assumed_role_credential_type" {
#   value       = module.aws_secrets.vault_role_assumed_role_credential_type
#   description = "The Vault role for AWS `assumed_role` credential type."
# }