###################################################################################################
# Environment
###################################################################################################


terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {}
}





###################################################################################################
# Resource Group 
###################################################################################################

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "UKSOUTH"
}



###################################################################################################
# Key Vault
###################################################################################################


module "key_vault_1" {
  source              = "mikesmake/kv/azurerm"
  version             = "0.0.1"
  resource_group_name = azurerm_resource_group.rg.name
  key_vault_name      = var.key_vault_name


  depends_on = [azurerm_resource_group.rg]
}


###################################################################################################
# IDIT Server 1
###################################################################################################


module "idit-1" {
  source              = "mikesmake/vm/azurerm"
  version             = "0.0.2"
  resource_group_name = azurerm_resource_group.rg.name
  vnet = {
    name                = var.vm_vnet_name
    resource_group_name = var.vm_vnet_rg_name
  }
  nic_subnet_name = var.nic_subnet_name
  key_vault_name  = module.key_vault_1.key_vault_name
  vm_name = {
    service                = "dvlpmt"
    environment_letter     = "D"
    role                   = "app"
    vm_number              = var.vm1_number
    environment_short_name = ""
  }
  virtual_machine_size = "Standard_DS3_v2"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"
  }
  vm_disks = [
    {
      lun                  = 10
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 100
    }
  ]
  tags                      = var.tags
  join_domain               = true
  active_directory_username = var.active_directory_username
  active_directory_password = var.active_directory_password



  depends_on = [azurerm_resource_group.rg, module.key_vault_1]

}

###################################################################################################
# IDIT Server 2
###################################################################################################


module "idit-2" {
  source              = "mikesmake/vm/azurerm"
  version             = "0.0.2"
  resource_group_name = azurerm_resource_group.rg.name
  vnet = {
    name                = var.vm_vnet_name
    resource_group_name = var.vm_vnet_rg_name
  }
  nic_subnet_name = var.nic_subnet_name
  key_vault_name  = module.key_vault_1.key_vault_name
  vm_name = {
    service                = "dvlpmt"
    environment_letter     = "D"
    role                   = "app"
    vm_number              = var.vm2_number
    environment_short_name = ""
  }
  virtual_machine_size = "Standard_DS3_v2"
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "latest"

  }
  vm_disks = [
    {
      lun                  = 10
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 100
    }
  ]
  tags                      = var.tags
  join_domain               = true
  active_directory_username = var.active_directory_username
  active_directory_password = var.active_directory_password

  depends_on = [azurerm_resource_group.rg, module.key_vault_1]

}

###################################################################################################
# SQL Server 1
###################################################################################################

module "sql-1" {
  source              = "mikesmake/vm/azurerm"
  version             = "0.0.2"
  resource_group_name = azurerm_resource_group.rg.name
  vnet = {
    name                = var.vm_vnet_name
    resource_group_name = var.vm_vnet_rg_name
  }

  nic_subnet_name = var.nic_subnet_name
  key_vault_name  = module.key_vault_1.key_vault_name
  vm_name = {
    service                = "dvlpmt"
    environment_letter     = "D"
    role                   = "SQL"
    vm_number              = var.sql1_number
    environment_short_name = ""
  }
  virtual_machine_size = "Standard_DS11_v2"
  source_image_reference = {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2016sp2-ws2019"
    sku       = "sqldev"
    version   = "latest"
  }
  vm_disks = [
    {
      lun                  = 10
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 20
    },

    {
      lun                  = 20
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 850
    },

    {
      lun                  = 30
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 500
    },

    {
      lun                  = 40
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 50
    }


  ]

  tags                      = var.tags
  join_domain               = true
  active_directory_username = var.active_directory_username
  active_directory_password = var.active_directory_password

  depends_on = [azurerm_resource_group.rg, module.key_vault_1]

}

###################################################################################################
# Network Load Balancer
###################################################################################################

module "nlb" {
  source = "./nlb"

  resource_group_name = data.azurerm_resource_group.resource_group.name
  vnet_name           = var.vm_vnet_name
  vnet_resource_group = var.vm_vnet_rg_name
  subnet_name         = var.nic_subnet_name
  nlb_name            = var.nlb_name
  front_end_name      = var.front_end_name
  backend_pool_name   = var.lb_backend_pool_name
  health_probe_port   = var.health_probe_port
  health_probe_name   = var.health_probe_name
  rule_name           = var.rule_name
  backend_port        = 9080
  frontend_port       = 9080

  back_end_vms = {
    ipconfig = {
      nic_id = module.idit-1.virtual_machine_nic_id
    }
    ipconfig2 = {
      nic_id = module.idit-2.virtual_machine_nic_id
    }
  }

  depends_on = [module.idit-1, module.idit-2]
}