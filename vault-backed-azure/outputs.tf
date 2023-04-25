output "vnet_address_space" {
  description = "Deployed VNet CIDR Range"
  value       = azurerm_virtual_network.main.address_space
}

output "vm_public_ip" {
  description = "Public IP of the deployed VM"
  value = azurerm_linux_virtual_machine.example.public_ip_address
}