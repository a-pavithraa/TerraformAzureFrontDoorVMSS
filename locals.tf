locals {
  virtual_network_cidr = "10.123.0.0/16"
  subnets = {
    app_subnet = {
      nsg_inbound = {
        rule1 = {
          name                       = "weballow"
          priority                   = "100"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "80"
          source_address_prefix      = "AzureFrontDoor.Backend"
          source_port_range          = "*"
          destination_address_prefix = "0.0.0.0/0"
        }
        rule2 = {
          name                       = "weballow1"
          priority                   = "101"
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "0.0.0.0/0"
      } }


      nsg_outbound_rules = [
        # [name, priority, direction, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        # To use defaults, use "" without adding any values.
        ["ntp_out", "103", "Outbound", "Allow", "Udp", "123", "", "0.0.0.0/0"],
      ]
    }
  }
  autoscaling_rules = {
    rule1 = {

    }
    rule2 = {

    }
  }



}

