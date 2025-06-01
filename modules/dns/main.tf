resource "cloudflare_dns_record" "this" {
  for_each = toset(var.hostnames)
  zone_id = var.zone_id
  comment = "Created by Terraform"
  content = var.origin_server_ip
  name = each.value
  proxied = true
  ttl = 1
  type = "A"
}
