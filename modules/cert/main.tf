data "cloudflare_zone" "this" {
  zone_id = var.zone_id
}

resource "tls_private_key" "this" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

locals {
  dns_names = formatlist("%s.%s", var.hostnames, data.cloudflare_zone.this.name)
}

resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
  dns_names = local.dns_names
}

resource "cloudflare_origin_ca_certificate" "this" {
  csr = tls_cert_request.this.cert_request_pem
  hostnames = local.dns_names
  request_type = "origin-rsa"
  requested_validity = 5475
}

output "certificate" {
  value = cloudflare_origin_ca_certificate.this.certificate
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
}
