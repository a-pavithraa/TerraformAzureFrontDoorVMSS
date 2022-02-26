output "be_poolid" {
  value = azurerm_lb_backend_address_pool.bpepool.id
}
output "nat_poolid" {
  value = azurerm_lb_nat_pool.natpol.id
}
output "lb_publicip" {
  value = azurerm_public_ip.lb_publicip
}
