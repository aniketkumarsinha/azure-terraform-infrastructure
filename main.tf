# Configure Azure Provider
terraform {
  required_providers {
    azurerm = "hashicorp/azurerm"
    version = ">= 3.59.0"
  }
  required_version = ">= 0.14.9"
}

