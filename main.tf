terraform {
  required_providers {
      azurerm = {
          source = "hashicorp/azurerm"
          version = ">=2.73.0"
      }
  }
}

################### data providers #################################################

# get resource group to deploy to
data "azurerm_resource_group" "rg" {
    name = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
    name = var.subnet_name
    virtual_network_name = var.vnet_name
    resource_group_name = var.vnet_resource_group
}


################### resource providers #############################################

#create nlb
resource "azurerm_lb" "nlb" {
  name                = var.nlb_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.front_end_name
    subnet_id            = data.azurerm_subnet.subnet.id

        
  }
}


#create backend pool
resource "azurerm_lb_backend_address_pool" "backpool" {
  loadbalancer_id = azurerm_lb.nlb.id
  name            = var.backend_pool_name

  depends_on = [azurerm_lb.nlb]
}


#tie nic to backend pool 
resource "azurerm_network_interface_backend_address_pool_association" "VMLink" {

for_each = var.back_end_vms

  network_interface_id    = each.value["nic_id"]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backpool.id

depends_on = [azurerm_lb_backend_address_pool.backpool]

}


#create health probe
resource "azurerm_lb_probe" "healthprobe" {
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.nlb.id
  name                = var.health_probe_name
  port                = var.health_probe_port

depends_on = [azurerm_lb.nlb]
  
}



#create rule
resource "azurerm_lb_rule" "nlbrule" {
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.nlb.id
  name                           = var.rule_name
  protocol                       = var.rule_protocol
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = var.front_end_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backpool.id
  probe_id                       = azurerm_lb_probe.healthprobe.id

depends_on = [azurerm_lb_probe.healthprobe,azurerm_lb.nlb,azurerm_lb_backend_address_pool.backpool]
  
}
