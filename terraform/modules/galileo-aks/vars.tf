variable "create_resource_group" {
  type     = bool
  default  = true
}

variable "location" {
  default = "centralus"
}

variable "resource_group_name" {
  type    = string
  default = "galileo"
}

variable "vnet_cidr" {
  type    = string
  default = "10.52.0.0/16"
}

variable "default_subnet_cidr" {
  type    = string
  default = "10.52.0.0/22"
}

variable "resource_prefix" {
  type    = string
  default = "galileo"
}

variable "public_network_access_enabled" {
  type     = bool
  default  = true
}