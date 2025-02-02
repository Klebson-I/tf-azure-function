data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfrg" {
  name     = "${var.owner}-${var.environment}-function-rg"
  location = "Canada Central"
}

resource "azurerm_storage_account" "functionsa" {
  name                     = "${var.function_sa_name}${var.owner}${var.environment}"
  resource_group_name      = azurerm_resource_group.tfrg.name
  location                 = azurerm_resource_group.tfrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functionsp" {
  name                = "${var.function_sp_name}${var.owner}${var.environment}"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "functionapp" {
  name                = "${var.function_app_name}${var.owner}${var.environment}"
  resource_group_name = azurerm_resource_group.tfrg.name
  location            = azurerm_resource_group.tfrg.location
  storage_account_name       = azurerm_storage_account.functionsa.name
  storage_account_access_key = azurerm_storage_account.functionsa.primary_access_key
  service_plan_id        = azurerm_service_plan.functionsp.id
  depends_on = [azurerm_storage_account.functionsa]
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
  }
  site_config {
    application_stack {
      node_version = "~16"
    }
  }
}