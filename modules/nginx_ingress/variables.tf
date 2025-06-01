variable "certificate" {
  type        = string
  description = "the certificate to use for the ingress controller"
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "the private key to use for the ingress controller"
}
