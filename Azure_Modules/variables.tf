
variable "system" {
    type = string
    description = "Name of the system or environment"
}

variable "location" {}
    #description = "value of azure location"
    #default = "uksouth"

variable "host_name" {}

variable "admin_username" {
    type = string
    description = "username"
}

variable "admin_password" {
    type = string
    description = "password"
}