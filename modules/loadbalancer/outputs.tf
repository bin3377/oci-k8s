output "load_balancer_public_ip" {
  value = join(",", [for ip in oci_network_load_balancer_network_load_balancer.this.ip_addresses : ip.ip_address if ip.is_public == true])
}
