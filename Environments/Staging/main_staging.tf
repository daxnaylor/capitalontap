terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

module "staging-azure-network" {
  source = "../../Azure_Modules"
  system = "staging"
  location = "uksouth"
  admin_username = "Admin"
  admin_password = "my$admin"
}








