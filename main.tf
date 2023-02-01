terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "vmrg" {
  name     = "testrg"
  location = "West Europe"
}

