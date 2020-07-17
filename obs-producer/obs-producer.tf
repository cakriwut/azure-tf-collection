resource "azurerm_public_ip" "streamer" {
 count                        = var.vm_to_create
 name                         = format("${var.vm_base_name}-public-ip-%02d",count.index)
 location                     = azurerm_resource_group.streamer.location
 resource_group_name          = azurerm_resource_group.streamer.name
 allocation_method            = "Static" 
 domain_name_label            = format("${var.vm_base_name}-%02d",count.index)
 tags                         = var.tags
}

resource "azurerm_network_interface" "streamer" {
    count = var.vm_to_create
    name =  format("${var.vm_base_name}-nic-%02d",count.index)
    location = azurerm_resource_group.streamer.location
    resource_group_name = azurerm_resource_group.streamer.name

    ip_configuration {
        name = "${var.vm_base_name}-nic-config"
        subnet_id = azurerm_subnet.streamer.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.streamer[count.index].id
    }
    tags = var.tags
  
}

resource "azurerm_windows_virtual_machine" "streamer" {     
   lifecycle {
      prevent_destroy = false 
   }
   
   count = var.vm_to_create
   name = format("${var.vm_base_name}-%02d",count.index)
   location = azurerm_resource_group.streamer.location
   resource_group_name = azurerm_resource_group.streamer.name
   network_interface_ids = [azurerm_network_interface.streamer[count.index].id]
   size = var.vm_size
   admin_username =  var.admin_username
   admin_password = var.admin_password
   custom_data = filebase64("init.ps1")

   provision_vm_agent = true

   additional_unattend_content {
        setting = "AutoLogon"
        content = data.template_file.auto_logon.rendered
   }

   additional_unattend_content {
        setting = "FirstLogonCommands"
        content = data.template_file.first_logon_command.rendered
   }

   source_image_reference {
       publisher = "MicrosoftWindowsDesktop"
       offer = "Windows-10"
       sku = "20h1-pro"
       version = "latest"
   }

   os_disk {
       caching = "ReadWrite"
       storage_account_type = "StandardSSD_LRS"
   }
}

resource "azurerm_virtual_machine_extension" "streamer-bginfo" {
  count = var.vm_to_create
  name                 = "BGInfo"
  virtual_machine_id = azurerm_windows_virtual_machine.streamer[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "BGInfo"
  type_handler_version = "2.1"  
  depends_on           = [azurerm_virtual_machine_extension.streamer-customscript]
}

resource "azurerm_virtual_machine_extension" "streamer-nvidia" {
  count = var.vm_to_create
  name                 = "NvidiaGpuDriverWindows"
  virtual_machine_id = azurerm_windows_virtual_machine.streamer[count.index].id
  publisher            = "Microsoft.HpcCompute"
  type                 = "NvidiaGpuDriverWindows"
  type_handler_version = "1.3"  
  depends_on           = [azurerm_virtual_machine_extension.streamer-bginfo]
}


resource "azurerm_virtual_machine_extension" "streamer-customscript" {
  count = var.vm_to_create
  name                 = "CustomScript"
  virtual_machine_id   = azurerm_windows_virtual_machine.streamer[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  
  protected_settings = jsonencode({
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted  -Command \"$env:AdminUser='${var.admin_username}'; $env:AdminPassword='${var.admin_password}'; copy-item c:\\AzureData\\CustomData.bin c:\\init.ps1;& c:\\init.ps1; Remove-Item c:\\Init.ps1 -Force; exit 0;\""
  })

  tags = var.tags
}