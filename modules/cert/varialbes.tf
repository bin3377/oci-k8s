variable "zone_id" {
  type        = string
  description = "the id of the zone to create the origin ca certificate in"
}
  
variable "hostnames" {
  type        = list(string)
  description = "the hostnames to create the origin ca certificate for"
  default = ["*"]
}
