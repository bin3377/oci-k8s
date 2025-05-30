locals {
  health_checker_port = 10256
}

data "oci_core_vcn" "this" {
  vcn_id = var.vcn_id
}

data "oci_core_subnet" "private" {
  subnet_id = var.private_subnet_id
}

data "oci_core_subnet" "public" {
  subnet_id = var.public_subnet_id
}

resource "oci_network_load_balancer_network_load_balancer" "this" {
  compartment_id = var.compartment_id
  subnet_id      = data.oci_core_subnet.public.id
  display_name   = "${var.prefix}-nlb"

  is_private                     = false
  is_preserve_source_destination = false

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

data "oci_containerengine_node_pool" "node_pool" {
  node_pool_id = var.node_pool_id
}

resource "oci_network_load_balancer_backend_set" "this" {
  health_checker {
    protocol = "TCP"
    port     = local.health_checker_port
  }
  name                     = "${var.prefix}-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = false
}

locals {
  node_ids = data.oci_containerengine_node_pool.node_pool.nodes[*].id
}

resource "oci_network_load_balancer_backend" "this" {
  count                    = length(local.node_ids)
  backend_set_name         = oci_network_load_balancer_backend_set.this.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  port                     = var.node_port
  target_id                = local.node_ids[count.index]
}

resource "oci_network_load_balancer_listener" "this" {
  name                     = "${var.prefix}-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.this.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  port                     = "80"
  protocol                 = "TCP"
}
