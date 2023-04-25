resource "vault_gcp_secret_backend" "gcp" {
  credentials = base64decode(google_service_account_key.vault_mount_key.private_key)
  description = "Google Cloud secrets engine"
}

resource "vault_gcp_secret_roleset" "roleset_viewer" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_viewer"
  secret_type  = "access_token"
  project      = var.project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
    roles = [
      "roles/viewer",
    ]
  }
}

resource "vault_gcp_secret_roleset" "roleset_editor" {
  backend      = vault_gcp_secret_backend.gcp.path
  roleset      = "project_editor"
  secret_type  = "access_token"
  project      = var.project_id
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
    roles = [
      "roles/editor",
    ]
  }
}
