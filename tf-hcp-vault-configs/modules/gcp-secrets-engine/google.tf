resource "google_service_account" "vault_mount_user" {
  account_id   = "vault-service-account"
  display_name = "VaultServiceAccount"
  description  = "Service account for the Vault secrets engine"
}

resource "google_project_iam_custom_role" "vault_mount_role" {
  role_id     = "VaultServiceRole"
  title       = "VaultServiceRole"
  description = "Role for the Vault secrets engine"
  permissions = [
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.list",
    "iam.serviceAccounts.update",
    "iam.serviceAccountKeys.create",
    "iam.serviceAccountKeys.delete",
    "iam.serviceAccountKeys.get",
    "iam.serviceAccountKeys.list",
    "iam.serviceAccounts.getAccessToken",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}

resource "google_project_iam_binding" "vault_mount_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.vault_mount_role.name

  members = [
    "serviceAccount:${google_service_account.vault_mount_user.email}"
  ]
}

resource "google_service_account_key" "vault_mount_key" {
  service_account_id = google_service_account.vault_mount_user.name
}
