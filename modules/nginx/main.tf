resource "kubernetes_namespace" "this" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_config_map" "this" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.this.id
  }

  data = {
    "nginx.conf" = <<-EOF
      events {
      }
      http {
        server {
          listen 80;
          location / {
            return 200 "Hello from Oracle Cloud!";
          }
        }
      }
    EOF
  }
}

resource "kubernetes_deployment" "this" {
  depends_on = [ kubernetes_config_map.this ]
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
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        automount_service_account_token = false
        enable_service_links = false
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
          volume_mount {
            name = "config-vol"
            mount_path = "/etc/nginx/"
          }
        }
        volume {
          name = "config-vol"
          config_map {
            name = "nginx-config"
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
    labels = {
      app = "nginx"
    }
    annotations = {
      "oci.oraclecloud.com/load-balancer-type" = "nlb"
    }
  }
  spec {
    type = "LoadBalancer"
    external_traffic_policy = "Cluster"
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}

output "load_balancer_public_ip" {
  value = kubernetes_service.this.status[0].load_balancer[0].ingress[0].ip
}
