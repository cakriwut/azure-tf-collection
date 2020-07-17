variable "resource_group_name" {
   description = "Resource Group name for this deployment"  
}

variable "location" {
   description = "Deployment location, the region such as southeastasia, westus, etc."
}

variable "vm_to_create" {
    description = "How many VM to create"
}

variable "admin_username" {
    description = "User"
}

variable "admin_password" {
    description = "Password"
}

variable "vm_size" {
   description = "VM size"
   default = "Standard_B4ms"
}