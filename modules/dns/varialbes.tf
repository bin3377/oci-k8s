variable "zone_id" {
  type        = string
  description = "the id of the zone to create the dns record in"
}
  
variable "hostnames" {
  type        = list(string)
  description = "the hostnames to create the dns record for"
  default = ["*"]
}

variable "origin_server_ip" {
  type        = string
  description = "the origin server ip to create DNS record for"
}