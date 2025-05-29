resource "kubernetes_namespace" "this" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.this.id
  }
  spec {
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:1.14.2"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.this.id
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
      node_port   = var.node_port
    }

    type = "NodePort"
  }
}
