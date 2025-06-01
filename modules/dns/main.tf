data "cloudflare_zone" "this" {
  zone_id = var.zone_id
}

locals {
  dns_names = formatlist("%s.%s", var.hostnames, data.cloudflare_zone.this.name)
}

resource "cloudflare_dns_record" "this" {
  for_each = toset(local.dns_names)
  zone_id  = var.zone_id
  comment  = "Created by Terraform"
  content  = var.origin_server_ip
  name     = each.value
  proxied  = true
  ttl      = 1
  type     = "A"
}
