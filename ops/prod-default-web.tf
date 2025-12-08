# ----------------------
# Default web entrypoint
# ----------------------

# Namespace
resource "kubernetes_namespace" "prod-default-web" {
  metadata {
    name = "prod-default-web"
  }
}

# Ingress
resource "kubernetes_ingress_v1" "prod-default-web" {
  metadata {
    name      = "prod-default-web-ingress"
    namespace = kubernetes_namespace.prod-default-web.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer" = module.cert_manager.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-errors@kubernetescrd"
    }
  }

  spec {
    default_backend {
      service {
        name = kubernetes_service_v1.prod-default-web.metadata.0.name
        port {
          number = 80
        }
      }
    }

    rule {
      host = var.cluster_dns_management
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.prod-default-web.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [
        "${var.cluster_dns_management}"
      ]

      secret_name = "prod-default-web-cert"
    }
  }

  depends_on = [
    kubernetes_namespace.prod-default-web,
    kubernetes_service_v1.prod-default-web,
    module.cert_manager,
  ]
}

# Service
resource "kubernetes_service_v1" "prod-default-web" {
  metadata {
    name      = "prod-default-web"
    namespace = kubernetes_namespace.prod-default-web.metadata.0.name
  }

  spec {
    selector = {
      app = "prod-default-web"
    }

    port {
      port        = 80
      target_port = 5678
    }
  }

  depends_on = [
    kubernetes_deployment_v1.prod-default-web
  ]
}

# Deployment
resource "kubernetes_deployment_v1" "prod-default-web" {
  metadata {
    name      = "prod-default-web"
    namespace = kubernetes_namespace.prod-default-web.metadata.0.name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "prod-default-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "prod-default-web"
        }
      }

      spec {
        container {
          name  = "prod-default-web"
          image = "hashicorp/http-echo"
          args = [
            "-text=Welcome to CTF Pilot!"
          ]

          port {
            container_port = 5678
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.prod-default-web
  ]
}
