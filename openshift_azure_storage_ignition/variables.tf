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

variable "tag_cost_center" {
  description = "Cost center tag used for charge back"
}

variable "tag_environment" {
  description = "Environment tag used for organizational queries (e.g. Production, Performance, UAT, QA, Test, Development)"
}

variable "tag_tier" {
  description = "Tier tag used for organizational support queries (e.g. T0, T1, T2, T3, T4)"
}