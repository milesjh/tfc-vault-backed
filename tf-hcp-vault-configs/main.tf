terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    # google = {
    #   version = "~> 4.0"
    #   source  = "hashicorp/google"
    # }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.44"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.2"
    }
  }

  cloud {
    organization = "milesjh-sandbox"
    workspaces {
      name = "tf-hcp-vault-configs"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# provider "google" {
#   project = var.google_project_id
#   region  = "global"
# }

data "tfe_organization" "current" {
  name = var.tfc_organization
}

data "tfe_outputs" "tf-admin" {
  organization = var.tfc_organization
  workspace = "tf-admin"
}

data "tfe_outputs" "tf-hcp-vault" {
  organization = var.tfc_organization
  workspace    = "tf-hcp-vault"
}

provider "vault" {
  address   = data.tfe_outputs.tf-hcp-vault.values.vault_public_endpoint_url
  token     = data.tfe_outputs.tf-hcp-vault.values.vault_admin_token
  namespace = "admin"
}

resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "example" {
  mount        = vault_mount.kvv2.path
  max_versions = 5
}

module "jwt_auth" {
  source                = "./modules/jwt-auth"
  tfc_organization_name = var.tfc_organization
  tfc_vault_role        = var.tfc_vault_role
  tfc_project_name      = "*"
  tfc_workspace_name    = "*"
}

module "aws_secrets" {
  source        = "./modules/aws-secrets-engine"
  email_address = data.tfe_organization.current.email
}

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

resource "tfe_variable_set" "vault_backed_aws_iam" {
  organization = var.tfc_organization
  name         = "AWS Vault-Backed Dynamic Credentials - IAM User"
  description  = "Vault-backed dynamic credentials for AWS provider using iam_user."
}

resource "tfe_variable" "vault_backed_aws_iam" {
  for_each = {
    TFC_VAULT_PROVIDER_AUTH             = "true"
    TFC_VAULT_ADDR                      = data.tfe_outputs.tf-hcp-vault.values.vault_public_endpoint_url
    TFC_VAULT_NAMESPACE                 = "admin"
    TFC_VAULT_RUN_ROLE                  = var.tfc_vault_role
    TFC_VAULT_BACKED_AWS_AUTH           = "true"
    TFC_VAULT_BACKED_AWS_AUTH_TYPE      = "iam_user"
    TFC_VAULT_BACKED_AWS_RUN_VAULT_ROLE = module.aws_secrets.vault_role_iam_user_credential_type
  }

  category        = "env"
  key             = each.key
  value           = each.value
  variable_set_id = tfe_variable_set.vault_backed_aws_iam.id
}

resource "tfe_workspace_variable_set" "vault_backed_aws" {
  variable_set_id = tfe_variable_set.vault_backed_aws.id
  workspace_id      = data.tfe_outputs.tf-admin.values.aws_workspace_id
}

# module "google_secrets" {
#   count      = var.google_project_id == null ? 0 : 1
#   source     = "./modules/gcp-secrets-engine"
#   project_id = var.google_project_id
# }

# resource "tfe_variable_set" "vault_backed_gcp" {
#   organization = var.tfc_organization
#   name         = "GCP Vault-Backed Dynamic Credentials"
#   description  = "Vault-backed dynamic credentials for Google Cloud provider using roleset/access_token."
# }

# resource "tfe_variable" "vault_backed_gcp" {
#   for_each = {
#     TFC_VAULT_PROVIDER_AUTH                  = "true"
#     TFC_VAULT_ADDR                           = data.tfe_outputs.vault_cluster.values.vault_public_endpoint_url
#     TFC_VAULT_NAMESPACE                      = "admin"
#     TFC_VAULT_RUN_ROLE                       = var.tfc_vault_role
#     TFC_VAULT_BACKED_GCP_AUTH                = "true"
#     TFC_VAULT_BACKED_GCP_AUTH_TYPE           = "roleset/access_token"
#     TFC_VAULT_BACKED_GCP_PLAN_VAULT_ROLESET  = module.google_secrets[0].vault_role_gcp_viewer
#     TFC_VAULT_BACKED_GCP_APPLY_VAULT_ROLESET = module.google_secrets[0].vault_role_gcp_editor
#   }

#   category        = "env"
#   key             = each.key
#   value           = each.value
#   variable_set_id = tfe_variable_set.vault_backed_gcp.id
# }

# data "tfe_project" "gcp" {
#   name         = "Google"
#   organization = var.tfc_organization
# }

# resource "tfe_project_variable_set" "vault_backed_gcp" {
#   variable_set_id = tfe_variable_set.vault_backed_gcp.id
#   project_id      = data.tfe_project.gcp.id
# }
