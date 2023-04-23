output "available_regions" {
  description = "Regions currently available."
  value       = data.aws_regions.available.names
}

output "running_instance" {
  description = "Currently running instance IDs."
  value       = data.aws_instances.running.ids
}
