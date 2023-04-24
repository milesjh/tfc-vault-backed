output "vnet_address_space" {
  description = "Deployed VNet CIDR Range"
  value       = azurerm_virtual_network.main.address_space
}