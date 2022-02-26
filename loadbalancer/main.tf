#-- Load Balancer main

resource "azurerm_public_ip" "lb_publicip" {
  name                = "az_lb-public-ip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "az_lb" {
  name                = "${var.prefix}_az_lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.rg_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_publicip.id
  }

}
resource "azurerm_lb_nat_pool" "natpol" {

  name                           = "lb_natpool"
  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.az_lb.id
  protocol                       = "Tcp"
  frontend_port_start            = 50001
  frontend_port_end              = 50010
  backend_port                   = 3389
  frontend_ip_configuration_name = azurerm_lb.az_lb.frontend_ip_configuration[0].name
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.az_lb.id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_probe" "http" {
  resource_group_name = var.rg_name
  loadbalancer_id     = azurerm_lb.az_lb.id
  name                = "LBHTTPProbe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}
resource "azurerm_lb_rule" "http" {
  resource_group_name            = var.rg_name
  loadbalancer_id                = azurerm_lb.az_lb.id
  name                           = "LBHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  probe_id                       = azurerm_lb_probe.http.id
}