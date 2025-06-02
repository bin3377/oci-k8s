locals {
  shape_name = "MySQL.Free"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_mysql_mysql_configurations" "free" {
  compartment_id = var.compartment_id
  shape_name     = local.shape_name
}

resource "oci_mysql_mysql_db_system" "this" {
  compartment_id      = var.compartment_id
  subnet_id           = var.private_subnet_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape_name          = local.shape_name
  configuration_id    = data.oci_mysql_mysql_configurations.free.configurations[0].id
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  lifecycle {
    ignore_changes = [admin_username, admin_password]
  }
}

output "ip" {
  value       = oci_mysql_mysql_db_system.this.endpoints[0].ip_address
  description = "The IP address of the MySQL DB System."
}

output "port" {
  value       = oci_mysql_mysql_db_system.this.endpoints[0].port
  description = "The port of the MySQL DB System."
}
