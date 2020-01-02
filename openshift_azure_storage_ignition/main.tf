resource "random_string" "storage_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_account" "bootstrap" {
  name                     = "openshiftbootstrap${random_string.storage_suffix.result}"
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_storage_account" "master" {
  name                     = "openshiftmaster${random_string.storage_suffix.result}"
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_storage_account" "worker" {
  name                     = "openshiftworker${random_string.storage_suffix.result}"
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  tags = {
    APP_NAME = "OCP"
    OCP_CLUSTER = var.openshift_cluster_name
    COST_CENTER = var.tag_cost_center
    ENVIRONMENT = var.tag_environment
    TIER = var.tag_tier
  }
}

resource "azurerm_storage_container" "bootstrap_ignition" {
  name                  = "ignition"
  storage_account_name  = azurerm_storage_account.bootstrap.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "master_ignition" {
  name                  = "ignition"
  storage_account_name  = azurerm_storage_account.master.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "worker_ignition" {
  name                  = "ignition"
  storage_account_name  = azurerm_storage_account.worker.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "bootstrap_ignition" {
  connection_string = azurerm_storage_account.bootstrap.primary_connection_string
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

data "azurerm_storage_account_sas" "master_ignition" {
  connection_string = azurerm_storage_account.master.primary_connection_string
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
  expiry = timeadd(timestamp(), "87600h")

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

data "azurerm_storage_account_sas" "worker_ignition" {
  connection_string = azurerm_storage_account.worker.primary_connection_string
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
  expiry = timeadd(timestamp(), "87600h")

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

resource "azurerm_storage_blob" "bootstrap_ignition" {
  name                   = "bootstrap.ign"
  source                 = "${var.ignition_directory}/bootstrap.ign"
  storage_account_name   = azurerm_storage_account.bootstrap.name
  storage_container_name = azurerm_storage_container.bootstrap_ignition.name
  type                   = "block"
}

resource "azurerm_storage_blob" "master_ignition" {
  name                   = "bootstrap.ign"
  source                 = "${var.ignition_directory}/master.ign"
  storage_account_name   = azurerm_storage_account.master.name
  storage_container_name = azurerm_storage_container.master_ignition.name
  type                   = "block"
}

resource "azurerm_storage_blob" "worker_ignition" {
  name                   = "bootstrap.ign"
  source                 = "${var.ignition_directory}/worker.ign"
  storage_account_name   = azurerm_storage_account.worker.name
  storage_container_name = azurerm_storage_container.worker_ignition.name
  type                   = "block"
}