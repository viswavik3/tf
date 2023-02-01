terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "vmrg" {
  name     = "testrg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vmvnet" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmrg.location
  resource_group_name = azurerm_resource_group.vmrg.name
}

resource "azurerm_subnet" "vmsub" {
  name                 = "test"
  resource_group_name  = azurerm_resource_group.vmrg.name
  virtual_network_name = azurerm_virtual_network.vmvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vmnic" {
  name                = "test"
  location            = azurerm_resource_group.vmrg.location
  resource_group_name = azurerm_resource_group.vmrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vmsub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vmip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "testvm-machine"
  resource_group_name = azurerm_resource_group.vmrg.name
  location            = azurerm_resource_group.vmrg.location
  size                = "Standard_B1s"
  admin_username      = "viswa"
  admin_password      = "Qwertyuiop@123"
  disable_password_authentication = false 
  network_interface_ids = [
    azurerm_network_interface.vmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "vmip" {
  name                = "testip"
  resource_group_name = azurerm_resource_group.vmrg.name
  location            = azurerm_resource_group.vmrg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "vmnsg" {
  name                = "testnsg"
  location            = azurerm_resource_group.vmrg.location
  resource_group_name = azurerm_resource_group.vmrg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "vmnsga" {
  subnet_id                 = azurerm_subnet.vmsub.id
  network_security_group_id = azurerm_network_security_group.vmnsg.id
}
