variable "cluster_name" {
  description = "Unique OpenShift cluster identifier"
}

variable "azure_resource_group_name" {
  description = "Name of azure resource group to deploy resources into"
}

variable "azure_location" {
  description = "The region to deploy resources into"
}

variable "instance_size" {
  description = "Instance size for Bootstrap instance"
}

variable "subnet_id" {
  description = "Subnet to deploy instance into"
}