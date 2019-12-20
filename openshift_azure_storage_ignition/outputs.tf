output "bootstrap_ignition_source_uri" {
  value = "${azurerm_storage_blob.bootstrap_ignition.url}${data.azurerm_storage_account_sas.bootstrap_ignition.sas}"
}

output "master_ignition_source_uri" {
  value = "${azurerm_storage_blob.master_ignition.url}${data.azurerm_storage_account_sas.master_ignition.sas}"
}

output "worker_ignition_source_uri" {
  value = "${azurerm_storage_blob.worker_ignition.url}${data.azurerm_storage_account_sas.worker_ignition.sas}"
}