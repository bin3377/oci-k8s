module "network" {
  source                   = "./modules/network"
  compartment_id           = var.compartment_id
  prefix                   = "k8s"
  enable_ipv6              = false
  vcn_cidr                 = "10.0.0.0/16"
  private_subnet_cidr      = "10.0.0.0/24"
  public_subnet_cidr       = "10.0.1.0/24"
  public_subnet_open_ports = [80, 6443] // HTTP, Kubectl

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

module "cluster" {
  source             = "./modules/cluster"
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.33.0"
  prefix             = "k8s"
  vcn_id             = module.network.vcn_id
  private_subnet_id  = module.network.private_subnet_id
  public_subnet_id   = module.network.public_subnet_id
  ssh_public_key     = var.ssh_public_key

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

output "cluster_id" {
  value = module.cluster.cluster_id
}
