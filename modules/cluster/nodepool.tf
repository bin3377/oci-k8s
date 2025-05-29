data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "latest_image" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  filter {
    name   = "display_name"
    values = ["^.*-aarch64-.*$"]
    regex  = true
  }
}

resource "oci_containerengine_node_pool" "this" {
  compartment_id     = var.compartment_id
  cluster_id         = oci_containerengine_cluster.this.id
  kubernetes_version = var.kubernetes_version
  name               = "${var.prefix}-node-pool"

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = data.oci_core_subnet.private.id
      }
    }
    size = 2
  }
  node_shape = "VM.Standard.A1.Flex"

  node_shape_config {
    memory_in_gbs = 6
    ocpus         = 1
  }

  node_source_details {
    image_id    = data.oci_core_images.latest_image.images[0].id
    source_type = "image"
  }

  initial_node_labels {
    key   = "name"
    value = "${var.prefix}-cluster"
  }

  ssh_public_key = var.ssh_public_key

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
