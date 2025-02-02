terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.90.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "lk-dev-sa-rg"
    storage_account_name = "lkdevsa"
    container_name       = "dev"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}