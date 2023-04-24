output "workspace_id" {
  for_each = var.workspace_names
  value       = tfe_workspace.main["each.key"].id
  description = "ID of the workspace."
}