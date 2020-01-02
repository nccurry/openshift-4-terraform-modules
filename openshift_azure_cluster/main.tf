# Load Balancers

resource "azurerm_network_security_group" "api-lb" {
  name = "openshift-${var.openshift_cluster_name}-api-lb"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_security_rule" "api-lb-api" {
    name = "openshift-${var.openshift_cluster_name}-api-lb-api"
    resource_group_name = var.azure_resource_group_name
    network_security_group_name = azurerm_network_security_group.api-lb.name
    description = "API traffic from external"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "6443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    access = "Allow"
    priority = "101"
    direction = "Inbound"
}

resource "azurerm_network_security_rule" "api-lb-machine-config" {
    name = "openshift-${var.openshift_cluster_name}-api-lb-machine-config"
    resource_group_name = var.azure_resource_group_name
    network_security_group_name = azurerm_network_security_group.api-lb.name
    description = "MachineConfig traffic from bootstrap / master"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22623"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    access = "Allow"
    priority = "102"
    direction = "Inbound"
}

resource "azurerm_lb" "api-lb" {
  name = "openshift-${var.openshift_cluster_name}-api-lb"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  frontend_ip_configuration {
    name = "openshift-${var.openshift_cluster_name}-api-lb-config"
    subnet_id = var.azure_subnetwork_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_lb_backend_address_pool" "api-lb" {
  name = "openshift-${var.openshift_cluster_name}-api-lb"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id     = azurerm_lb.api-lb.id
}

resource "azurerm_lb_rule" "api-lb-https" {
  name = "openshift-${var.openshift_cluster_name}-api-lb-https"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.api-lb.id
  frontend_ip_configuration_name = "openshift-${var.openshift_cluster_name}-api-lb-config"
  protocol = "Tcp"
  frontend_port = "6443"
  backend_port = "6443"
  backend_address_pool_id = azurerm_lb_backend_address_pool.api-lb.id
  probe_id = azurerm_lb_probe.api-lb-https.id
}

resource "azurerm_lb_probe" "api-lb-https" {
  name = "openshift-${var.openshift_cluster_name}-api-lb-https"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.api-lb.id
  protocol = "Tcp"
  port = "6443"
}

resource "azurerm_lb_rule" "api-lb-machine-config" {
  name = "openshift-${var.openshift_cluster_name}-api-lb-machine-config"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.api-lb.id
  frontend_ip_configuration_name = "openshift-${var.openshift_cluster_name}-api-lb-config"
  protocol = "Tcp"
  frontend_port = "22623"
  backend_port = "22623"
  backend_address_pool_id = azurerm_lb_backend_address_pool.api-lb.id
  probe_id = azurerm_lb_probe.api-lb-machine-config.id
}

resource "azurerm_lb_probe" "api-lb-machine-config" {
  name = "openshift-${var.openshift_cluster_name}-api-lb-machine-config"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.api-lb.id
  protocol = "Tcp"
  port = "22623"
}

resource "azurerm_network_security_group" "ingress-lb" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_security_rule" "ingress-lb-http" {
    name = "openshift-${var.openshift_cluster_name}-ingress-lb-http"
    resource_group_name = var.azure_resource_group_name
    network_security_group_name = azurerm_network_security_group.ingress-lb.name
    description = "Ingress http from external"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    access = "Allow"
    priority = "101"
    direction = "Inbound"
}

resource "azurerm_network_security_rule" "ingress-lb-https" {
    name = "openshift-${var.openshift_cluster_name}-ingress-lb-https"
    resource_group_name = var.azure_resource_group_name
    network_security_group_name = azurerm_network_security_group.ingress-lb.name
    description = "Ingress http from external"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    access = "Allow"
    priority = "102"
    direction = "Inbound"
}

resource "azurerm_lb" "ingress-lb" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  frontend_ip_configuration {
    name = "openshift-${var.openshift_cluster_name}-ingress-lb-config"
    subnet_id = var.azure_subnetwork_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_lb_backend_address_pool" "ingress-lb" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id     = azurerm_lb.ingress-lb.id
}

resource "azurerm_lb_rule" "ingress-lb-https" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb-https"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.ingress-lb.id
  frontend_ip_configuration_name = "openshift-${var.openshift_cluster_name}-ingress-lb-config"
  protocol = "Tcp"
  frontend_port = "443"
  backend_port = "443"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ingress-lb.id
  probe_id = azurerm_lb_probe.ingress-lb-http.id
}

resource "azurerm_lb_rule" "ingress-lb-http" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb-http"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.ingress-lb.id
  frontend_ip_configuration_name = "openshift-${var.openshift_cluster_name}-ingress-lb-config"
  protocol = "Tcp"
  frontend_port = "80"
  backend_port = "80"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ingress-lb.id
  probe_id = azurerm_lb_probe.ingress-lb-http.id
}

resource "azurerm_lb_probe" "ingress-lb-http" {
  name = "openshift-${var.openshift_cluster_name}-ingress-lb-http"
  resource_group_name = var.azure_resource_group_name
  loadbalancer_id = azurerm_lb.ingress-lb.id
  protocol = "Tcp"
  port = "80"
}

# Boot diagnostics storage
resource "random_string" "storage_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_account" "boot-diagnostics" {
  name                     = "openshiftbootdiag${random_string.storage_suffix.result}"
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Bootstrap

resource "azurerm_network_security_group" "bootstrap" {
  count = var.bootstrap_replicas
  name = "openshift-${var.openshift_cluster_name}-bootstrap"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_security_rule" "bootstrap-ssh" {
  count = var.bootstrap_replicas
  name = "openshift-${var.openshift_cluster_name}-bootstrap-ssh"
  resource_group_name = var.azure_resource_group_name
  network_security_group_name = element(azurerm_network_security_group.bootstrap.*.name, count.index)
  description = "SSH traffic from external"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  access = "Allow"
  priority = "100"
  direction = "Inbound"
}

resource "azurerm_network_interface" "bootstrap" {
  count = var.bootstrap_replicas
  name = "openshift-${var.openshift_cluster_name}-bootstrap-nic"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_security_group_id = element(azurerm_network_security_group.bootstrap.*.id, count.index)
  ip_configuration {
    name = "openshift-${var.openshift_cluster_name}-bootstrap-nic-config"
    subnet_id = var.azure_subnetwork_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "bootstrap" {
  count = var.bootstrap_replicas
  network_interface_id    = element(azurerm_network_interface.bootstrap.*.id, count.index)
  ip_configuration_name   = "openshift-${var.openshift_cluster_name}-bootstrap-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.api-lb.id
}

data "ignition_config" "bootstrap-redirect" {
  replace {
    source = var.bootstrap_ignition_source_uri
  }
}

resource "azurerm_virtual_machine" "bootstrap" {
  count = var.bootstrap_replicas
  name = "openshift-${var.openshift_cluster_name}-bootstrap"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_interface_ids = [
    element(azurerm_network_interface.bootstrap.*.id, count.index)
  ]
  os_profile_linux_config {
    disable_password_authentication = false
  }
  vm_size = var.bootstrap_instance_size
  availability_set_id = azurerm_availability_set.master.id
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name = "openshift-${var.openshift_cluster_name}-bootstrap"
    admin_username = "core"
    admin_password = "NotActuallyApplied!"
    custom_data    = data.ignition_config.bootstrap-redirect.rendered
  }
  storage_os_disk {
    name = "openshift-${var.openshift_cluster_name}-bootstrap-disk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 100
  }
  storage_image_reference {
    id = var.azure_rhcos_image_id
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.boot-diagnostics.primary_blob_endpoint
  }
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

# Master

resource "azurerm_network_security_group" "master" {
  name = "openshift-${var.openshift_cluster_name}-master"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_security_rule" "master-ssh" {
  name = "openshift-${var.openshift_cluster_name}-master-ssh"
  resource_group_name = var.azure_resource_group_name
  network_security_group_name = azurerm_network_security_group.master.name
  description = "SSH traffic from external"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  access = "Allow"
  priority = "100"
  direction = "Inbound"
}

resource "azurerm_availability_set" "master" {
  name                = "openshift-${var.openshift_cluster_name}-master"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  managed = true
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_interface" "master" {
  count = 3
  name = "openshift-${var.openshift_cluster_name}-master-nic-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_security_group_id = azurerm_network_security_group.master.id
  ip_configuration {
    name = "openshift-${var.openshift_cluster_name}-master-nic-config"
    subnet_id = var.azure_subnetwork_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "master" {
  count = 3
  network_interface_id    = element(azurerm_network_interface.master.*.id, count.index)
  ip_configuration_name   = "openshift-${var.openshift_cluster_name}-master-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.api-lb.id
}

data "ignition_config" "master-redirect" {
  replace {
    source = var.master_ignition_source_uri
  }
}

resource "azurerm_virtual_machine" "master" {
  depends_on = [
    azurerm_virtual_machine.bootstrap
  ]
  count = 3
  name = "openshift-${var.openshift_cluster_name}-master-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_interface_ids = [
    element(azurerm_network_interface.master.*.id, count.index)
  ]
  os_profile_linux_config {
    disable_password_authentication = false
  }
  vm_size = var.master_instance_size
  availability_set_id = azurerm_availability_set.master.id
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name = "openshift-${var.openshift_cluster_name}-master-${count.index}"
    admin_username = "core"
    admin_password = "NotActuallyApplied!"
    custom_data    = data.ignition_config.master-redirect.rendered
  }
  storage_os_disk {
    name = "openshift-${var.openshift_cluster_name}-master-${count.index}-disk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 200
//    managed_disk_id = element(azurerm_managed_disk.master.*.id, count.index)
//    os_type = "Linux"
  }
  storage_image_reference {
    id = var.azure_rhcos_image_id
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.boot-diagnostics.primary_blob_endpoint
  }
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

# Worker

resource "azurerm_network_security_group" "worker" {
  name = "openshift-${var.openshift_cluster_name}-worker"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_availability_set" "worker" {
  name                = "openshift-${var.openshift_cluster_name}-worker"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  managed = true
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_network_interface" "worker" {
  count = var.worker_replicas
  name = "openshift-${var.openshift_cluster_name}-worker-nic-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_security_group_id = azurerm_network_security_group.worker.id
  ip_configuration {
    name = "openshift-${var.openshift_cluster_name}-worker-nic-config"
    subnet_id = var.azure_subnetwork_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count = var.worker_replicas
  network_interface_id    = element(azurerm_network_interface.worker.*.id, count.index)
  ip_configuration_name   = "openshift-${var.openshift_cluster_name}-worker-nic-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ingress-lb.id
}

data "ignition_config" "worker-redirect" {
  replace {
    source = var.worker_ignition_source_uri
  }
}

resource "azurerm_virtual_machine" "worker" {
  depends_on = [
    azurerm_virtual_machine.master
  ]
  count = var.worker_replicas
  name = "openshift-${var.openshift_cluster_name}-worker-${count.index}"
  resource_group_name = var.azure_resource_group_name
  location = var.azure_location
  network_interface_ids = [
    element(azurerm_network_interface.worker.*.id, count.index)
  ]
  os_profile_linux_config {
    disable_password_authentication = false
  }
  vm_size = var.worker_instance_size
  availability_set_id = azurerm_availability_set.worker.id
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  os_profile {
    computer_name = "openshift-${var.openshift_cluster_name}-worker-${count.index}"
    admin_username = "core"
    admin_password = "NotActuallyApplied!"
    custom_data    = data.ignition_config.worker-redirect.rendered
  }
  storage_os_disk {
    name = "openshift-${var.openshift_cluster_name}-worker-${count.index}-disk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = 200
  }
  storage_image_reference {
    id = var.azure_rhcos_image_id
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.boot-diagnostics.primary_blob_endpoint
  }
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

# DNS Entries

resource "azurerm_private_dns_a_record" "api-public" {
  name = "api.${var.openshift_cluster_name}"
  resource_group_name = var.azure_dns_zone_resource_group_name
  zone_name = var.azure_dns_zone_name
  ttl = 300
  records = [
    azurerm_lb.api-lb.private_ip_address
  ]
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_private_dns_a_record" "api-private" {
  name = "api-int.${var.openshift_cluster_name}"
  resource_group_name = var.azure_dns_zone_resource_group_name
  zone_name = var.azure_dns_zone_name
  ttl = 300
  records = [
    azurerm_lb.api-lb.private_ip_address
  ]
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_private_dns_a_record" "ingress" {
  name = "*.apps.${var.openshift_cluster_name}"
  resource_group_name = var.azure_dns_zone_resource_group_name
  zone_name = var.azure_dns_zone_name
  ttl = 300
  records = [
    azurerm_lb.ingress-lb.private_ip_address
  ]
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_private_dns_a_record" "etcd" {
  count = 3
  name = "etcd-${count.index}.${var.openshift_cluster_name}"
  resource_group_name = var.azure_dns_zone_resource_group_name
  zone_name = var.azure_dns_zone_name
  ttl = 300
  records = [
    element(azurerm_network_interface.master.*.private_ip_address, count.index)
  ]
}

resource "azurerm_private_dns_srv_record" "etcd" {
  name = "_etcd-server-ssl._tcp.${var.openshift_cluster_name}"
  resource_group_name = var.azure_dns_zone_resource_group_name
  zone_name = var.azure_dns_zone_name
  ttl = 300
  record {
    port = 2380
    priority = 0
    target = "etcd-0.${var.openshift_cluster_name}.${var.azure_dns_zone_name}"
    weight = 10
  }
  record {
    port = 2380
    priority = 0
    target = "etcd-1.${var.openshift_cluster_name}.${var.azure_dns_zone_name}"
    weight = 10
  }
    record {
    port = 2380
    priority = 0
    target = "etcd-2.${var.openshift_cluster_name}.${var.azure_dns_zone_name}"
    weight = 10
  }
}