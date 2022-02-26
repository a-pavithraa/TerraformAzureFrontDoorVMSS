#Virtual machine scale set resource
data "azurerm_shared_image_version" "ServerImage" {
  name                = "recent"
  image_name          = "todoimage"
  gallery_name        = "azvmgallery"
  resource_group_name = "az-image"
}


resource "azurerm_windows_virtual_machine_scale_set" "Az-Demo1" {
  name                = "vmscaleset"
  location            = var.location
  resource_group_name = var.rg_name

  sku                  = "Standard_E2as_v4"
  instances            = 1
  admin_username       = var.admin_user
  admin_password       = var.admin_password
  computer_name_prefix = "pills123"
  source_image_id      = data.azurerm_shared_image_version.ServerImage.id



  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"

  }



  network_interface {

    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [var.be_poolid]
      primary                                = true
    }
  }
  /*extension {
    name                       = "CustomScript"
    publisher                  = "Microsoft.Compute"
    type                       = "CustomScriptExtension"
    type_handler_version       = "1.10"
    auto_upgrade_minor_version = true

    settings = jsonencode({ "commandToExecute" = "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf-script.rendered)}')) | Out-File -filepath commands.ps1\" && powershell -ExecutionPolicy Unrestricted -File commands.ps1" })

    protected_settings = jsonencode({ "managedIdentity" = {} })
  }*/
}

#auto scalling resource settings

resource "azurerm_monitor_autoscale_setting" "Az-Demo1" {
  name                = "monitorscale"
  resource_group_name = var.rg_name
  location            = var.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.Az-Demo1.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.Az-Demo1.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 60
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.Az-Demo1.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["admin@contoso.com"]
    }
  }
}
#-----------------------------------------------------------
# Install Tomcat web server in every Instance in VM scale sets 
#-----------------------------------------------------------
resource "azurerm_virtual_machine_scale_set_extension" "vmss-tomcat" {

  name                         = "install-tomcat"
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.9"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.Az-Demo1.id
  protected_settings           = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command $Env:CATALINA_HOME = \"C:/tomcat/apache-tomcat-9.0.46-windows-x64/apache-tomcat-9.0.46\""
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
      "commandToExecute" : "powershell.exe -Command C:/tomcat/apache-tomcat-9.0.46-windows-x64/apache-tomcat-9.0.46/bin/startup.bat"
    }
  SETTINGS
}

