terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

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

provider "tfe"{}

data "tfe_organization" "current" {
  name = var.tfc_organization
}

data "tfe_outputs" "tf-admin" {
  organization = var.tfc_organization
  workspace    = "tf-admin"
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

#######KVv2#########

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

resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.kvv2.path
  name                = "secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar",
      admin_username = "${var.admin_username}",
      admin_password = "${var.admin_password}"
    }
  )
}

#######JWT#########

module "jwt_auth" {
  source                = "./modules/jwt-auth"
  tfc_organization_name = var.tfc_organization
  tfc_vault_role        = var.tfc_vault_role
  tfc_project_name      = "*"
  tfc_workspace_name    = "*"
}

#######AWS#########

module "aws_secrets" {
  source        = "./modules/aws-secrets-engine"
  email_address = data.tfe_organization.current.email
}

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

resource "tfe_workspace_variable_set" "vault_backed_aws_iam" {
  variable_set_id = tfe_variable_set.vault_backed_aws_iam.id
  workspace_id    = data.tfe_outputs.tf-admin.values.aws_workspace_id
}

#######AZURE#########

module "azure_secrets" {
  source          = "./modules/azure-secrets-engine"
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  rg_name         = var.rg_name
}

resource "tfe_variable_set" "vault_backed_azure" {
  organization = var.tfc_organization
  name         = "Azure Vault-Backed Dynamic Credentials"
  description  = "Vault-backed dynamic credentials for Azure provider."
}

resource "tfe_variable" "vault_backed_azure" {
  for_each = {
    TFC_VAULT_PROVIDER_AUTH               = "true"
    TFC_VAULT_ADDR                        = data.tfe_outputs.tf-hcp-vault.values.vault_public_endpoint_url
    TFC_VAULT_NAMESPACE                   = "admin"
    TFC_VAULT_RUN_ROLE                    = var.tfc_vault_role
    TFC_VAULT_BACKED_AZURE_AUTH           = "true"
    TFC_VAULT_BACKED_AZURE_RUN_VAULT_ROLE = module.azure_secrets.vault_azure_role
    ARM_SUBSCRIPTION_ID                   = var.subscription_id
    ARM_TENANT_ID                         = var.tenant_id
  }

  category        = "env"
  key             = each.key
  value           = each.value
  variable_set_id = tfe_variable_set.vault_backed_azure.id
}

resource "tfe_variable" "azure_rg_name" {
  category        = "terraform"
  key             = "rg_name"
  value           = "milesjh-sandbox-rg"
  variable_set_id = tfe_variable_set.vault_backed_azure.id
}

resource "tfe_workspace_variable_set" "vault_backed_azure" {
  variable_set_id = tfe_variable_set.vault_backed_azure.id
  workspace_id    = data.tfe_outputs.tf-admin.values.azure_workspace_id
}

