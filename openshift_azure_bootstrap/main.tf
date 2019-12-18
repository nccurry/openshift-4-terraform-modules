resource "random_string" "storage_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_container" "ignition" {
  name                  = "ignition"
  storage_account_name  = azurerm_storage_account.cluster.name
  container_access_type = "private"
}

resource "azurerm_network_security_group" "bootstrap" {
  name = "${var.cluster_name}-bootstrap"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {}
}

resource "azurerm_network_security_rule" "bootstrap-ssh" {
  name = "${var.cluster_name}-bootstrap-ssh"
  resource_group_name = var.azure_resource_group_name
  network_security_group_name = azurerm_network_security_group.bootstrap.name
  description = "SSH traffic from external"
  protocol = "Tcp"
  source_port_range = "22"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  access = "Allow"
  priority = "100"
  direction = "Inbound"
}

data "azurerm_storage_account_sas" "ignition" {
  connection_string = azurerm_storage_account.cluster.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "24h")

  permissions {
    read    = true
    list    = true
    create  = false
    add     = false
    delete  = false
    process = false
    write   = false
    update  = false
  }
}

resource "azurerm_storage_blob" "ignition" {
  name                   = "bootstrap.ign"
  source                 = "${var.ocp_ignition_dir}/bootstrap.ign"
  storage_account_name   = azurerm_storage_account.cluster.name
  storage_container_name = azurerm_storage_container.ignition.name
  type                   = "block"
}

data "ignition_config" "bootstrap-redirect" {
  replace {
    source = "${azurerm_storage_blob.ignition.url}${data.azurerm_storage_account_sas.ignition.sas}"
  }
}

resource "azurerm_network_interface" "bootstrap" {
  name = "${var.cluster_name}-bootstrap-nic"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_security_group_id = azurerm_network_security_group.bootstrap.id
  ip_configuration {
    name = "${var.cluster_name}-bootstrap-nic-config"
    subnet_id = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "bootstrap" {
  network_interface_id    = element(azurerm_network_interface.bootstrap.*.id, count.index)
  ip_configuration_name   = "${var.cluster_name}-bootstrap-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.api-lb.id
}

resource "azurerm_virtual_machine" "bootstrap" {
  depends_on = [
    azurerm_storage_blob.ignition
  ]
  name = "${var.cluster_name}-bootstrap"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_interface_ids = [
    azurerm_network_interface.bootstrap.id
  ]
  os_profile_linux_config {
    disable_password_authentication = false
  }
  vm_size = var.instance_size
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name = "${var.cluster_name}-bootstrap"
    admin_username = "core"
    admin_password = "NotActuallyApplied!"
    custom_data    = data.ignition_config.bootstrap-redirect.rendered
  }
  storage_os_disk {
    name = "${var.cluster_name}-bootstrap-disk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 100
  }
  storage_image_reference {
    id = var.az_rhcos_image_id
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.cluster.primary_blob_endpoint
  }
  tags = {}
}