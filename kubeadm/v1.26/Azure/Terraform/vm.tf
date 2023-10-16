
resource "azurerm_public_ip" "default" {
  count               = var.node_count
  name                = "${var.app_name}-public-ip-${count.index}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Static"
  zones               = ["${count.index % var.location_max_az + 1}"]
  sku                 = "Standard" # Standard is required to use zones https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku
}

resource "azurerm_network_interface" "default" {
  count               = var.node_count
  name                = "${var.app_name}-nic-${count.index}"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.default[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "default" {
  count                         = var.node_count
  network_interface_id          = azurerm_network_interface.default[count.index].id
  network_security_group_id     = azurerm_network_security_group.default.id
}

resource "azurerm_linux_virtual_machine" "main" {
  count                 = var.node_count
  name                  = "${var.app_name}-vm-${count.index}"
  location              = azurerm_resource_group.default.location
  resource_group_name   = azurerm_resource_group.default.name
  network_interface_ids = [azurerm_network_interface.default[count.index].id]
  size                  = "Standard_DS1_v2"
  admin_username        = var.vm_admin_username
  admin_password        = var.vm_admin_password
  disable_password_authentication = false
  # availability zone
  zone = count.index % var.location_max_az + 1 # 1, 2,..var.location_max_az, 1, 2,..var.location_max_az...

  # https://az-vm-image.info/
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-confidential-vm-jammy"
    sku       = "22_04-lts-cvm"
    version   = "22.04.202210040"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}