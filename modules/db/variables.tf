variable "compartment_id" {
  type        = string
  description = "compartment id where to create all resources."
}

variable "private_subnet_id" {
  type        = string
  description = "The id of the private subnet."
}

variable "admin_username" {
  type        = string
  description = "The admin username for the MySQL DB System."
  default     = "admin"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "The admin password for the MySQL DB System."
}