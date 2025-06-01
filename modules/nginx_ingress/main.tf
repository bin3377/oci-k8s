resource "kubernetes_namespace" "this" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_secret" "cert" {
  metadata {
    name      = "tls-cert"
    namespace = kubernetes_namespace.this.id
  }
  data = {
    "tls.crt" = var.certificate
    "tls.key" = var.private_key
  }
  type = "tls"
}

resource "helm_release" "this" {
  depends_on = [kubernetes_namespace.this]
  name       = "ingress-nginx"
  namespace  = kubernetes_namespace.this.id
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.12.2"

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = kubernetes_secret.cert.id
  }
}

data "kubernetes_service" "controller" {
  depends_on = [helm_release.this]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.this.id
  }
}

output "load_balancer_public_ip" {
  value = data.kubernetes_service.controller.status[0].load_balancer[0].ingress[0].ip
}
