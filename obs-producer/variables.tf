variable "resource_group_name" {
   description = "Resource Group name for this deployment"  
}

variable "location" {
   description = "Deployment location, the region such as southeastasia, westus, etc."
}

variable "vm_to_create" {
    description = "How many VM to create"
}

variable "vm_base_name" {
    description = "Basename"
    default = "streamer"
}

variable "vm_size" {
   description = "VM size"
   default = "Standard_NV12_Promo"
}

variable "admin_username" {
    description = "User"
}

variable "admin_password" {
    description = "Password"
}

variable "tags" {
    description = "Deployment tags"
    type        = map(string)
}

