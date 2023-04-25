resource "vault_azure_secret_backend" "azure" {
  use_microsoft_graph_api = true
  subscription_id         = var.subscription_id
  tenant_id               = var.tenant_id
  client_id               = var.client_id
  client_secret           = var.client_secret
  environment             = "AzurePublicCloud"
}

# resource "vault_azure_secret_backend_role" "role" {
#   backend = vault_azure_secret_backend.azure.path
#   role    = "generated_role"
#   ttl     = 300
#   max_ttl = 600

#   azure_roles {
#     role_name = "Contributor"
#     scope     = "/subscriptions/${var.subscription_id}/resourceGroups/${var.rg_name}"
#   }
# }

resource "vault_azure_secret_backend_role" "role1" {
  backend = vault_azure_secret_backend.azure.path
  role    = "generated_role"
  ttl     = 300
  max_ttl = 600

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${var.subscription_id}"
  }
}
