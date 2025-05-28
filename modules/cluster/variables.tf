variable "compartment_id" {
  type        = string
  description = "compartment id where to create all resources."
}

variable "kubernetes_version" {
  type        = string
  description = "version of the kubernetes cluster."
}

variable "prefix" {
  type        = string
  description = "The prefix of all resources name."
}

variable "vcn_id" {
  type        = string
  description = "VCN id the kubernetes cluster host in."
}

variable "private_subnet_id" {
  type        = string
  description = "The id of the private subnet."
}

variable "public_subnet_id" {
  type        = string
  description = "The id of the public subnet."
}

variable "ssh_public_key" {
  type        = string
  description = "The public key for SSH to worker node."
}

variable "freeform_tags" {
  type        = map(any)
  description = "simple key-value pairs to tag the created resources using freeform OCI Free-form tags."
}

variable "defined_tags" {
  type        = map(string)
  description = "predefined and scoped to a namespace to tag the resources created using defined tags."
}
