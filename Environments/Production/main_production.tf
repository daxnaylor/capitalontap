terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  backend "remote" {
    organisation = "Dax-Cloud"
    Workspaces {
      name = "daxcloudinfrastructure"
    }
  }
}

module "production-azure-network" {
  source = "../../Azure_Modules"
  system = "production"
  location = "uksouth"
  admin_username = "Admin"
  admin_password = "my$admin"
}








