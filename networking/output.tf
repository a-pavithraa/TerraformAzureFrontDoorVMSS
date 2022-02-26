output "subnets_id" {
  value = azurerm_subnet.appsnet[*].id
}