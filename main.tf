data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfrg" {
  name     = "${var.owner}-${var.environment}-function-rg"
  location = "Canada Central"
}

resource "azurerm_storage_account" "functionSa" {
  name                     = "${var.function_sa_name}${var.owner}${var.environment}"
  resource_group_name      = azurerm_resource_group.tfrg.name
  location                 = azurerm_resource_group.tfrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "functionSp" {
  name                = "${var.function_sp_name}${var.owner}${var.environment}"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "functionApp" {
  name                = "${var.function_app_name}${var.owner}${var.environment}"
  resource_group_name = azurerm_resource_group.tfrg.name
  location            = azurerm_resource_group.tfrg.location
  storage_account_name       = azurerm_storage_account.functionSa.name
  storage_account_access_key = azurerm_storage_account.functionSa.primary_access_key
  service_plan_id        = azurerm_service_plan.functionSp.id
  depends_on = [azurerm_storage_account.functionSa]
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_CORS_ALLOWED_ORIGINS = "https://portal.azure.com"
  }
  site_config {
    application_stack {
      node_version = "~16"
    }
  }
}

resource "azurerm_function_app_function" "httpFunction" {
  name            = "${var.function_app_name}${var.owner}${var.environment}Function"
  function_app_id = azurerm_windows_function_app.functionApp.id
  language        = "Javascript"
  depends_on = [azurerm_windows_function_app.functionApp]

  file {
    name    = "index.js"
    content = file("script/index.js")
  }

  test_data = jsonencode({
    "name" = "Azure"
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "anonymous"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}