resource "azurerm_storage_account" "logstorage" {
  name                     = "logstorage12${substr(uuid(), 0, 3)}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_log_analytics_workspace" "loganalyticsworkspace" {
  name                = "${var.prefix}loganalyticsworkspace"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#--------------------------------------------------------------
# Azure Log Analytics Workspace Agent Installation for windows
#--------------------------------------------------------------
resource "azurerm_virtual_machine_scale_set_extension" "omsagentwin" {

  name                         = "OmsAgentForWindows"
  publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
  type                         = "MicrosoftMonitoringAgent"
  type_handler_version         = "1.0"
  auto_upgrade_minor_version   = true
  virtual_machine_scale_set_id = var.scaleset_id

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.loganalyticsworkspace.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    "workspaceKey": "${azurerm_log_analytics_workspace.loganalyticsworkspace.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}
resource "azurerm_monitor_diagnostic_setting" "vmmsdiag" {

  name                       = lower("${var.vmscaleset_name}-diag${substr(uuid(), 0, 3)}")
  target_resource_id         = var.scaleset_id
  storage_account_id         = azurerm_storage_account.logstorage.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loganalyticsworkspace.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "monitor-DependencyAgent-agent" {

  name = "vmext-monitorDepAgent-${var.vmscaleset_name}-${substr(uuid(), 0, 3)}"

  virtual_machine_scale_set_id = var.scaleset_id
  publisher                    = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                         = "DependencyAgentWindows"
  type_handler_version         = "9.5"
  auto_upgrade_minor_version   = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.loganalyticsworkspace.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    "workspaceKey": "${azurerm_log_analytics_workspace.loganalyticsworkspace.primary_shared_key}"
    }
PROTECTED_SETTINGS


}

