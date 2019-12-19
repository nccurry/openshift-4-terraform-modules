locals {
  # Get RHCOS filename from path to use for image name
  rhcos_image_name = element(split("/", var.rhcos_image_url), length(split("/", var.rhcos_image_url)) - 1)
}

resource "random_string" "storage_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_storage_account" "rhcos" {
  name                     = "openshiftrhcos${random_string.storage_suffix.result}"
  resource_group_name      = var.azure_resource_group_name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags {
    APP_NAME = "OCP"
  }
}

resource "azurerm_storage_container" "vhd" {
  name                 = "vhd"
  storage_account_name = azurerm_storage_account.rhcos.name
}

resource "azurerm_storage_blob" "rhcos_image" {
  name                   = "openshift-rhcos.vhd"
  resource_group_name = var.azure_resource_group_name
  storage_account_name   = azurerm_storage_account.rhcos.name
  storage_container_name = azurerm_storage_container.vhd.name
  type                   = "block"
  source_uri             = var.rhcos_image_url
  metadata               = map("source_uri", var.rhcos_image_url)
}

resource "azurerm_image" "rhcos" {
  name                = local.rhcos_image_name
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = azurerm_storage_blob.rhcos_image.url
  }

  tags {
    APP_NAME = "OCP"
  }
}
