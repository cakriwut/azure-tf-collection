terraform {
    required_providers {
        azurerm = "~> 2.19"
        template = "~> 2.1"
    }
}

provider "azurerm" {
    features {}
}

data "template_file" "auto_logon" {
    template = file("../extras/auto_logon.xml")

    vars = {
        admin_username = var.admin_username
        admin_password = var.admin_password
    }
}

data "template_file" "first_logon_command" {
    template = file("../extras/first_logon_cmd.xml")

    vars = {
        admin_username = var.admin_username
        admin_password = var.admin_password
    }
}