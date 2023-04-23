terraform {
  required_providers {
    vault = {
      version = "~> 3.0"
      source  = "hashicorp/vault"
    }
  }
}

resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = var.jwt_backend_path
  type               = "jwt"
  oidc_discovery_url = "https://${var.tfc_hostname}"
  bound_issuer       = "https://${var.tfc_hostname}"
}

resource "vault_jwt_auth_backend_role" "tfc_role" {
  backend        = vault_jwt_auth_backend.tfc_jwt.path
  role_name      = var.tfc_vault_role
  token_policies = [vault_policy.tfc_policy.name]

  bound_audiences = [var.tfc_vault_audience]

  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"
  }

  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

resource "vault_policy" "tfc_policy" {
  name = "tfc-policy"

  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

path "kv/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

path "aws/*" {
  capabilities = ["read"]
}

path "azure/*" {
  capabilities = ["read"]
}

path "gcp/*" {
  capabilities = ["read"]
}
EOT
}
