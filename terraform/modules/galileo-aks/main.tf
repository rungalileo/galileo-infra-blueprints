resource "random_id" "prefix" {
  byte_length = 8
}

resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, "${random_id.prefix.hex}-rg")
}

locals {
  resource_group = {
    name     = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
    location = var.location
  }
}

resource "azurerm_virtual_network" "test" {
  address_space       = [var.vnet_cidr]
  location            = local.resource_group.location
  name                = "${random_id.prefix.hex}-vn"
  resource_group_name = local.resource_group.name
}

resource "azurerm_subnet" "test" {
  address_prefixes                               = [var.default_subnet_cidr]
  name                                           = "${random_id.prefix.hex}-sn"
  resource_group_name                            = local.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  enforce_private_link_endpoint_network_policies = true
}

locals {
  nodes = {
    "grunner" = {
      name                = "grunner"
      vm_size             = "Standard_D8_v4"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 5
      os_disk_size_gb     = 60
      vnet_subnet_id      = azurerm_subnet.test.id
      node_labels = {
        "galileo-node-type" = "galileo-runner"
      }
    }
  }
}

module "aks_galileo" {
  source = "github.com/Azure/terraform-azurerm-aks.git?ref=6.8.0"

  prefix                            = "${var.resource_prefix}-${random_id.prefix.hex}"
  resource_group_name               = local.resource_group.name
  os_disk_size_gb                   = 60
  public_network_access_enabled     = var.public_network_access_enabled
  sku_tier                          = "Standard"
  role_based_access_control_enabled = true
  rbac_aad                          = false
  vnet_subnet_id                    = azurerm_subnet.test.id
  node_pools                        = local.nodes
  agents_min_count                  = 5
  agents_max_count                  = 7
  agents_labels = {
    "galileo-node-type" = "galileo-core"
  }
  agents_pool_name    = "gcore"
  agents_size         = "Standard_D4_v4"
  enable_auto_scaling = true
  kubernetes_version  = 1.25
  depends_on          = [azurerm_resource_group.main]
}