variable "azure_resource_group_name" {
  description = "Name of azure resource group to deploy resources into"
}

variable "azure_location" {
  description = "The region to deploy resources into"
}

variable "ignition_directory" {
  description = "The directory where ignition files are stored"
}

variable "openshift_cluster_name" {
  description = "Unique OpenShift cluster identifier"
}