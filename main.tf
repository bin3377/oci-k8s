module "network" {
  source                   = "./modules/network"
  compartment_id           = var.compartment_id
  prefix                   = "k8s"
  enable_ipv6              = false
  vcn_cidr                 = "10.0.0.0/16"
  private_subnet_cidr      = "10.0.0.0/24"
  public_subnet_cidr       = "10.0.1.0/24"
  public_subnet_open_ports = [80, 443, 6443] // HTTP, HTTPS, Kubectl

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

data "oci_containerengine_cluster_kube_config" "this" {
  cluster_id = module.cluster.cluster_id
}

locals {
  kubeconfig_cluster   = yamldecode(data.oci_containerengine_cluster_kube_config.this.content)["clusters"][0]["cluster"]
  kubeconfig_user_exec = yamldecode(data.oci_containerengine_cluster_kube_config.this.content)["users"][0]["user"]["exec"]
}

provider "kubernetes" {
  host                   = local.kubeconfig_cluster["server"]
  cluster_ca_certificate = base64decode(local.kubeconfig_cluster["certificate-authority-data"])

  exec {
    api_version = local.kubeconfig_user_exec["apiVersion"]
    args        = local.kubeconfig_user_exec["args"]
    command     = local.kubeconfig_user_exec["command"]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig_cluster["server"]
    cluster_ca_certificate = base64decode(local.kubeconfig_cluster["certificate-authority-data"])

    exec {
      api_version = local.kubeconfig_user_exec["apiVersion"]
      args        = local.kubeconfig_user_exec["args"]
      command     = local.kubeconfig_user_exec["command"]
    }
  }
}

# module "nginx" {
#   source     = "./modules/nginx"
#   cluster_id = module.cluster.cluster_id
# }

module "cert" {
  source    = "./modules/cert"
  zone_id   = var.cf_zone_id
  hostnames = ["*"]
}

module "nginx_ingress" {
  source      = "./modules/nginx_ingress"
  certificate = module.cert.certificate
  private_key = module.cert.private_key
}

module "dns" {
  source           = "./modules/dns"
  zone_id          = var.cf_zone_id
  hostnames        = ["*"]
  origin_server_ip = module.nginx_ingress.load_balancer_public_ip
}

output "load_balancer_public_ip" {
  value = module.nginx_ingress.load_balancer_public_ip
}

module "db" {
  source            = "./modules/db"
  compartment_id    = var.compartment_id
  private_subnet_id = module.network.private_subnet_id
  admin_username    = var.db_admin_username
  admin_password    = var.db_admin_password
}

output "db_ip" {
  value = module.db.ip
}

output "db_port" {
  value = module.db.port
}

data "cloudflare_zone" "zone" {
  zone_id = var.cf_zone_id
}

module "wordpress" {
  source = "./modules/wordpress"

  db_ip       = module.db.ip
  db_port     = module.db.port
  db_username = var.db_admin_username
  db_password = var.db_admin_password
  db_name     = "wordpress"

  hostname           = "${var.wordpress_hostname}.${data.cloudflare_zone.zone.name}"
  wordpress_username = var.wordpress_username
  wordpress_password = var.wordpress_password
}

output "wordpress_url" {
  value = module.wordpress.wordpress_url
}
