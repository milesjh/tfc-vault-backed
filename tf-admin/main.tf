terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.44"
    }
  }
}

data "tfe_organization" "current" {
  name = var.tfc_organization
}

data "tfe_oauth_client" "github" {
  organization     = data.tfe_organization.current.name
  service_provider = "github"
}

resource "tfe_project" "solution_series" {
  organization = data.tfe_organization.current.name
  name         = "Solution Series"
}

resource "tfe_workspace" "main" {
  for_each = var.workspace_names

  name                = each.key
  organization        = tfe_project.solution_series.organization
  project_id          = tfe_project.solution_series.id
  execution_mode      = "remote"
  working_directory   = each.key
  trigger_prefixes    = ["${each.key}"]
  global_remote_state = true
  terraform_version = "~>1.5"
  vcs_repo {
    identifier     = "milesjh/tfc-vault-backed"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }
}

resource "tfe_variable" "tf-hcp-vault" {
  for_each = var.tf-hcp-vault-vars

  key          = each.key
  value        = each.value
  category     = "terraform"
  workspace_id = tfe_workspace.main["tf-hcp-vault"].id
}

resource "tfe_variable" "tf-hcp-vault-configs" {
  for_each = var.tf-hcp-vault-configs-vars

  key          = each.key
  value        = each.value
  category     = "terraform"
  workspace_id = tfe_workspace.main["tf-hcp-vault-configs"].id
}
