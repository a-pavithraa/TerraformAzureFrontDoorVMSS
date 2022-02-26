resource "azurerm_public_ip" "pip1" {
  name                = "${var.prefix}-pip"
  resource_group_name = var.rg_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"
}

# resource "azurerm_network_interface_security_group_association" "Az-Demo1" {
#   network_interface_id      = azurerm_network_interface.internal1.id
#   network_security_group_id = azurerm_network_security_group.Az-Demo1.id
# }

resource "azurerm_network_interface" "internal1" {
  name                = "${var.prefix}-nic2"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}

#Below code is to create window virtual machine
resource "azurerm_windows_virtual_machine" "Az-Demo1" {
  name                = "winjump1"
  resource_group_name = var.rg_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.admin_user
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.internal1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = {
    "env" = "test"
  }
}