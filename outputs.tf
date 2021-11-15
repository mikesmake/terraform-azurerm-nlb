#As standard, output names + ID's for all created objects
#IE
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

