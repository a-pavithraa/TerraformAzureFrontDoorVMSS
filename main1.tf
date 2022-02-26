# create resource group
resource "azurerm_resource_group" "rgpoc" {
  name     = "${var.prefix}-1"
  location = var.location
}

module "networking" {
  source           = "./networking"
  app_subnet_count = 1
  prefix           = var.prefix
  rg_name          = azurerm_resource_group.rgpoc.name
  location         = var.location
  vn_cidr          = local.virtual_network_cidr
  app_subnet_cidrs = [for i in range(2, 20, 2) : cidrsubnet(local.virtual_network_cidr, 8, i)]
  sg_inbound       = local.subnets["app_subnet"]["nsg_inbound"]
  nsg_name         = "azpocnsg"

}

module "loadbalancer" {
  source   = "./loadbalancer"
  prefix   = var.prefix
  rg_name  = azurerm_resource_group.rgpoc.name
  location = var.location
}

module "frontdoor" {
  source      = "./frontdoor"
  lb_publicip = module.loadbalancer.lb_publicip
  prefix      = var.prefix
  rg_name     = azurerm_resource_group.rgpoc.name
  location    = var.location
}


module "scaleset" {
  source         = "./scaleset"
  prefix         = var.prefix
  rg_name        = azurerm_resource_group.rgpoc.name
  location       = var.location
  subnet_id      = module.networking.subnets_id[0]
  be_poolid      = module.loadbalancer.be_poolid
  admin_user     = var.admin_user
  admin_password = var.admin_password

}
/*module "bastion" {
  source    = "./bastion"
  prefix    = var.prefix
  rg_name   = azurerm_resource_group.rgpoc.name
  location  = var.location
  subnet_id = module.networking.subnets_id[0] 
  admin_user= var.admin_user
  admin_password = var.admin_password

}*/
module "monitoring" {
  source          = "./monitoring"
  vmscaleset_name = module.scaleset.vmscaleset_name
  prefix          = var.prefix
  rg_name         = azurerm_resource_group.rgpoc.name
  location        = var.location
  scaleset_id     = module.scaleset.scaleset_id


}
resource "azurerm_application_insights" "appinsights" {
  name                = "azpoc1-appinsights"
  location            = var.location
  resource_group_name = azurerm_resource_group.rgpoc.name
  application_type    = "web"
}
