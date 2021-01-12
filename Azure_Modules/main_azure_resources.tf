
# Create resource group
resource "azurerm_resource_group" "rg" {
    name     = "rg-${var.system}"
    location =  var.location
    tags     = {
      Environment = var.system
    }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${var.system}"
    address_space       = ["10.0.0.0/16"]
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.system}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "publicip-${var.system}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create load balancer 
resource "azurerm_lb" "lbalance" {
  name                = "lbalance-${var.system}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "FrontIP"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lbalance.id
  name                           = "lbrule-${var.system}"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "FrontIP"
}

resource "azurerm_lb_backend_address_pool" "bep" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lbalance.id
  name                = "BackEndPool"
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.system}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "sec-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }
}

# Subnet and network security group association
resource "azurerm_subnet_network_security_group_association" "sub-nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "nic-${count.index}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  count                     = 3 

  ip_configuration {
    name                          = "nicconf"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

# Nic and lb backend pool association
resource "azurerm_network_interface_backend_address_pool_association" "nic-pool" {
  network_interface_id    = azurerm_network_interface.nic[count.index]
  ip_configuration_name   = "nicconf"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bep.id
  count = 3
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [count.index % length(azurerm_network_interface.nic)]
  vm_size               = "Standard_DS1_v2"
  count                 = 3

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.host_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}