#-- main variables
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "az-new-poc"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "eastus"
}
variable "subscription_id" {

}
variable "app_subnet_count" {

}
variable "admin_user" {

}
variable "admin_password" {

}