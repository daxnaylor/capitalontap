terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  backend "azurerm" {
    storage_account_name = "storagedrm"
    container_name       = "drmcontainer"
    key                  = "daxcloud.terraform.tfstate"
    resource_group_name  = "Dax1"
    subscription_id      = "8f1922b2-591b-4f3f-9410-29e521617a56"
  }
}

provider "azurerm" {
  version = ">= 2.26"
  features {}
}

module "dev-azure-network" {
  source = "../../Azure_Modules"
  system = "dev"
  location = "uksouth"
  host_name = "vm-${count.index}"
  admin_username = "Admin"
  admin_password = "my$admin"
  count = 3
}





