
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
