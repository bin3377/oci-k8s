variable "compartment_id" {
  type        = string
  description = "compartment id where to create all resources."
}

variable "prefix" {
  type        = string
  description = "The prefix of all resources name."
}

variable "vcn_id" {
  type        = string
  description = "The id of the VCN."
}

variable "private_subnet_id" {
  type        = string
  description = "The id of the private subnet."
}

variable "public_subnet_id" {
  type        = string
  description = "The id of the public subnet."
}

variable "node_pool_id" {
  type        = string
  description = "The id of the workers node pool."
}

variable "node_port" {
  type        = number
  description = "The node port exposed by k8s service."
}

variable "freeform_tags" {
  type        = map(any)
  description = "simple key-value pairs to tag the created resources using freeform OCI Free-form tags."
}

variable "defined_tags" {
  type        = map(string)
  description = "predefined and scoped to a namespace to tag the resources created using defined tags."
}
