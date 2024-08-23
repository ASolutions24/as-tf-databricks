# Terraform State Backed Storage Details
variable "bkstrgrg" {
  type        = string
  description = "The name of the backend storage account resource group"
  default     = "bktfstorageRG"
}

variable "bkstrg" {
  type        = string
  description = "The name of the backend storage account"
  default     = "asstgtfstate"
}

variable "bkcontainer" {
  type = string
  description = "The container name for the backend config"
  default = "tfstate"
}

variable "bkstrgkey" {
  type = string
  description = "The access key for the storage account"
  default = "JQIa4AGikVSaEIfuz+TwAR/OJEBOnbNCaMMQXvTrdMdUL7EgWYHEzi2Ix19RBykoDTsJ3jbFz0g8+AStma+mdw=="
}


variable "env" {

}
variable "project" {
  
}

variable "location" {

}

variable "owner" {
    
}
variable "org" {
  
}
variable "source_code" {
  
}
variable "address_space" {
  type = list
  description = "VNET CIDR Range"
}
variable "subnets" {
  description = "A map to create multiple subnets"
  type = map(object({
    name = string
    address_space = list(string)
    subnet_delegation = string
  })) 
}

variable "nsg" {
  description = "A map of NSGs"
  type = map(object({
    name = string
  }))
  
}

/*
#####################################################
variable "owner" {
    description = "Owner name of the resource"
}

variable "purpose" {
    description = "Purpose of the resource"
}


variable "org" {
    description = "Org name / Client name"
  
}
variable "owner_custom" {
    description = "Short name of owner"
}

variable "purpose_custom" {
    description = "Custom purpose"
}

variable "address_space" {
  type = list
  description = "VNET CIDR Range"
}

variable "subnets" {
  description = "A map to create multiple subnets"
  type = map(object({
    name = string
    address_space = list(string)
    subnet_delegation = string
  })) 
}

variable "nsg" {
  description = "A map of NSGs"
  type = map(object({
    name = string
  }))
  
}

variable "private_link_subnet" {
    description = "ID of Private link Subnet"
  
}

variable "fw_subnet_id" {
  description = "ID of firewall Subnet"
}

variable "rt_public_subnet" {
  description = "ID of public ADB subnet"
}

variable "rt_private_subnet" {
  description = "ID of private ADB subnet"
}
*/