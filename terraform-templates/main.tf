terraform {
  backend "azurerm" {
    #resource_group_name = var.bkstrgrg
    #storage_account_name = var.bkstrg
    #container_name = var.bkcontainer
    #key = var.bkstrgkey
  }
  required_providers {
    azurerm = {
      #source  = "hashicorp/azurerm"
      #version = "=2.94.0"
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
    databricks = {
      #source  = "databrickslabs/databricks"
      #version = "=0.5.9"
      source  = "databricks/databricks"
      version = "1.27.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.43.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
provider "azuread" {
  # Configuration options
}
provider "time" {
  # Configuration options
}
provider "databricks" {
  azure_workspace_resource_id = module.adb.adb_id
}

module "rg" {
  #source = "./modules/resource-group"
  source = "../../a/tf-modules/content/modules/resource-group"
  owner = var.owner
  location = var.location
  project = var.project
  env = var.env
  org = var.org
  source_code = var.source_code
}

module "network" {
  source = "../../a/tf-modules/content/modules/network"
  env = var.env
  project = var.project
  address_space = var.address_space
  location = var.location
  subnets = var.subnets
  nsg = var.nsg
  depends_on = [ module.rg ]
}

module "firewall" {
  source = "../../a/tf-modules/content/modules/firewall"
  env = var.env
  project = var.project
  location = var.location
  fw_subnet_id = module.network.firewall_subnet
  rt_public_subnet = module.network.public_subnet_id
  rt_private_subnet = module.network.private_subnet_id
  depends_on = [ module.network ]
}

module "storageaccount" {
  source = "../../a/tf-modules/content/modules/storageaccount"
  env = var.env
  project = var.project
  location = var.location
  vnet_id = module.network.vnet_id
  private_link_subnet_id = module.network.private_link_subnet
  depends_on = [ module.rg,module.network ]
}

module "keyvault" {
  source = "../../a/tf-modules/content/modules/keyvault"
  env = var.env
  project = var.project
  location = var.location
  vnet_id = module.network.vnet_id
  private_link_subnet_id = module.network.private_link_subnet
  stacdata01_id = module.storageaccount.stacdata01_id
  depends_on = [ module.network, module.storageaccount ]
}

module "adb" {
  source = "../../a/tf-modules/content/modules/adb"
  env = var.env
  project = var.project
  location = var.location
  vnet_id = module.network.vnet_id
  public_subnet_network_security_group_association_id = module.network.public_nsg_association
  private_subnet_network_security_group_association_id = module.network.private_nsg_association
  key_vault_id = module.keyvault.kv_id
  key_vault_uri = module.keyvault.kv_uri
  stgaccname = module.storageaccount.stacdata01_name
  depends_on = [ module.network, module.keyvault, module.storageaccount ]
}

/*
module "network" {
  source         = "./modules/network"
  owner_custom   = var.owner_custom
  purpose_custom = var.purpose_custom
  address_space  = var.address_space
  location       = var.location
  subnets        = var.subnets
  nsg            = var.nsg
  depends_on     = [module.rg]
}

module "adb" {
  source                                               = "./modules/adb"
  owner_custom                                         = var.owner_custom
  purpose_custom                                       = var.purpose_custom
  location                                             = var.location
  vnet_id                                              = module.network.vnet_id
  public_subnet_network_security_group_association_id  = module.network.public_nsg_association
  private_subnet_network_security_group_association_id = module.network.private_nsg_association
  key_vault_id                                         = module.keyvault.kv_id
  key_vault_uri                                        = module.keyvault.kv_uri
  depends_on                                           = [module.network, module.keyvault]

}


module "keyvault" {
  source              = "./modules/keyvault"
  owner_custom        = var.owner_custom
  purpose_custom      = var.purpose_custom
  location            = var.location
  private_link_subnet = module.network.private_link_subnet
  vnet_id             = module.network.vnet_id
  depends_on = [ module.rg, module.network ]
}


module "db" {
  source              = "./modules/db"
  owner_custom        = var.owner_custom
  purpose_custom      = var.purpose_custom
  location            = var.location
  private_link_subnet = module.network.private_link_subnet
  key_vault_id        = module.keyvault.kv_id
  vnet_id             = module.network.vnet_id
  depends_on = [ module.rg, module.keyvault, module.network ]
}

module "firewall" {
  source = "./modules/firewall"
  owner_custom        = var.owner_custom
  purpose_custom      = var.purpose_custom
  location            = var.location
  fw_subnet_id = module.network.firewall_subnet
  rt_public_subnet = module.network.public_subnet_id
  rt_private_subnet = module.network.private_subnet_id
  depends_on = [ module.network ]
}
*/