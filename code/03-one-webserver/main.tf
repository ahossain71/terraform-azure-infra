# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1.0"
    }
  }
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
  use_msi = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  /*
  client_id       = var.client_id
  client_secret   = var.client_secret
  */
}

# Configure the Microsoft Azure Provider
/*
provider "azurerm" {
  features {}
  use_msi = true
  backend "azurerm" {
    storage_account_name = "abcd1234"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id  }
}
*/
# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "tftraining" {
  name     = "my-terraform-rg"
  location = "WEST EUROPE"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "tftraining" {
  name                = "my-terraform-vnet"
  location            = azurerm_resource_group.tftraining.location
  resource_group_name = azurerm_resource_group.tftraining.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "tftraining" {
  name                 = "my-terraform-subnet"
  resource_group_name  = azurerm_resource_group.tftraining.name
  virtual_network_name = azurerm_virtual_network.tftraining.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Public IP
resource "azurerm_public_ip" "tftraining" {
  name                = "my-terraform-public-ip"
  location            = azurerm_resource_group.tftraining.location
  resource_group_name = azurerm_resource_group.tftraining.name
  allocation_method   = "Static"

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "tftraining" {
  name                = "my-terraform-nsg"
  location            = azurerm_resource_group.tftraining.location
  resource_group_name = azurerm_resource_group.tftraining.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Interface
resource "azurerm_network_interface" "tftraining" {
  name                = "my-terraform-nic"
  location            = azurerm_resource_group.tftraining.location
  resource_group_name = azurerm_resource_group.tftraining.name

  ip_configuration {
    name                          = "my-terraform-nic-ip-config"
    subnet_id                     = azurerm_subnet.tftraining.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tftraining.id
  }

  tags = {
    environment = "my-terraform-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "tftraining" {
  network_interface_id      = azurerm_network_interface.tftraining.id
  network_security_group_id = azurerm_network_security_group.tftraining.id
}

# Get existing Key Vault
data "azurerm_key_vault" "my-DevOps-key-vault" {
  name                = "my-DevOps-key-vault"
  resource_group_name = "trng-DevOps-rgrp"
}

# Get existing Key
data "azurerm_key_vault_key" "my-trng-devops-ssh-key-02" {
  name         = "my-trng-devops-ssh-key-02"
  key_vault_id = data.azurerm_key_vault.my-DevOps-key-vault.id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "tftraining" {
  name                            = "my-terraform-vm"
  location                        = azurerm_resource_group.tftraining.location
  resource_group_name             = azurerm_resource_group.tftraining.name
  network_interface_ids           = [azurerm_network_interface.tftraining.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  #admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  admin_username                  = "azureuser"
  admin_ssh_key {
    username = "azureuser"
    public_key = data.azurerm_key_vault_key.my-trng-devops-ssh-key-02.public_key_openssh
  }
  disable_password_authentication = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-terraform-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  tags = {
    environment = "my-terraform-env"
  }
}

# Configurate to run automated tasks in the VM start-up
resource "azurerm_virtual_machine_extension" "tftraining" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.tftraining.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
      "commandToExecute": "echo 'Hello, World' > index.html ; nohup busybox httpd -f -p 8080 &"
    }
  SETTINGS

  tags = {
    environment = "my-terraform-env"
  }
}

# Data source to access the properties of an existing Azure Public IP Address
data "azurerm_public_ip" "tftraining" {
  name                = azurerm_public_ip.tftraining.name
  resource_group_name = azurerm_linux_virtual_machine.tftraining.resource_group_name
}

# Output variable: Public IP address
output "public_ip" {
  value = data.azurerm_public_ip.tftraining.ip_address
}
