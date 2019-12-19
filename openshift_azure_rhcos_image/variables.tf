variable "azure_resource_group_name" {
  description = "Name of azure resource group to deploy resources into"
}

variable "azure_location" {
  description = "The region to deploy resources into"
}

variable "rhcos_image_url" {
  description = "URL where azure rhcos vhd image is hosted"
}