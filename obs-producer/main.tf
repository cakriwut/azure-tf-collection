terraform {
    required_providers {
        azurerm = "~> 2.19"
        template = "~> 2.1"
    }
}

provider "azurerm" {
    features {}
}