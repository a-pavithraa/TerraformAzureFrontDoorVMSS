resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.prefix}-network-${var.location}"
  address_space       = [var.vn_cidr]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "appsnet" {
  count                = var.app_subnet_count
  name                 = "${var.prefix}-appsnet-${count.index}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.app_subnet_cidrs[count.index]]

}
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  resource_group_name = var.rg_name
  location            = var.location
  dynamic "security_rule" {
    for_each = var.sg_inbound
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = "Rule - ${security_rule.value.name} "
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  count                     = var.app_subnet_count
  subnet_id                 = azurerm_subnet.appsnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

