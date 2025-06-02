resource "kubernetes_namespace" "this" {
  metadata {
    name = "wordpress"
  }
}

resource "helm_release" "this" {
  depends_on = [kubernetes_namespace.this]
  name       = "wordpress"
  namespace  = kubernetes_namespace.this.id
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "wordpress"
  version    = "24.2.7"

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "externalDatabase.host"
    value = var.db_ip
  }

  set {
    name  = "externalDatabase.port"
    value = var.db_port
  }

  set {
    name  = "externalDatabase.database"
    value = var.db_name
  }

  set {
    name  = "externalDatabase.user"
    value = var.db_username
  }

  set {
    name  = "externalDatabase.password"
    value = var.db_password
  }

  set {
    name  = "ingress.hostname"
    value = var.hostname
  }

  set {
    name  = "wordpressUsername"
    value = var.wordpress_username
  }

  set {
    name  = "wordpressPassword"
    value = var.wordpress_password
  }

}

output "wordpress_url" {
  value = "https://${var.hostname}/login"
}
