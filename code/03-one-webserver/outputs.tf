output "resource_group_name" {
  value = azurerm_resource_group.tftraining.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.tftraining.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.training_ssh.private_key_pem
  sensitive = false
}