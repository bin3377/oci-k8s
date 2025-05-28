# private subnet
resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.prefix}-private-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = local.anywhere
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Auto-generated - allow all egress traffic"
  }

  dynamic "egress_security_rules" {
    for_each = var.enable_ipv6 == true ? [1] : []

    content {
      destination = local.anywhere_ipv6
      protocol    = "all"
      description = "Auto-generated - allow all egress traffic IPv6"
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    description = "Auto-generated - allow all ingress from VCN"
  }

  # ingress_security_rules {
  #   stateless   = false
  #   source      = var.private_subnet_cidr
  #   source_type = "CIDR_BLOCK"
  #   protocol    = "6"
  #   tcp_options {
  #     min = 10256
  #     max = 10256
  #   }
  # }

  # ingress_security_rules {
  #   stateless   = false
  #   source      = "10.0.0.0/24"
  #   source_type = "CIDR_BLOCK"
  #   protocol    = "6"
  #   tcp_options {
  #     min = 31600
  #     max = 31600
  #   }
  # }
}

resource "oci_core_subnet" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.prefix}-private-subnet"
  cidr_block     = var.private_subnet_cidr

  route_table_id             = oci_core_route_table.ngw.id
  security_list_ids          = [oci_core_security_list.private_sl.id]
  prohibit_public_ip_on_vnic = true
}

# public subnet
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.prefix}-public-subnet-sl"

  egress_security_rules {
    stateless        = false
    destination      = local.anywhere
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Auto-generated - allow all egress traffic"
  }

  dynamic "egress_security_rules" {
    for_each = var.enable_ipv6 == true ? [1] : []

    content {
      destination = local.anywhere_ipv6
      protocol    = "all"
      description = "Auto-generated - allow all egress traffic IPv6"
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    description = "Auto-generated - allow all ingress from VCN"
  }

  # egress_security_rules {
  #   stateless        = false
  #   destination      = "10.0.1.0/24"
  #   destination_type = "CIDR_BLOCK"
  #   protocol         = "6"
  #   tcp_options {
  #     min = 31600
  #     max = 31600
  #   }
  # }

  # egress_security_rules {
  #   stateless        = false
  #   destination      = "10.0.1.0/24"
  #   destination_type = "CIDR_BLOCK"
  #   protocol         = "6"
  #   tcp_options {
  #     min = 10256
  #     max = 10256
  #   }
  # }

  dynamic "ingress_security_rules" {
    for_each = var.public_subnet_open_ports

    content {
      protocol    = "6"
      source      = local.anywhere
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.enable_ipv6 ? var.public_subnet_open_ports : []

    content {
      protocol    = "6"
      source      = local.anywhere_ipv6
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }
}

resource "oci_core_subnet" "vcn_public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.prefix}-public-subnet"
  cidr_block     = var.public_subnet_cidr

  route_table_id    = oci_core_route_table.igw.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}