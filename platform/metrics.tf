resource "kubernetes_secret_v1" "ctfd_exporter" {
  metadata {
    name      = "ctfd-exporter"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      app = "ctfd-exporter"
    }
  }

  data = {
    CTFD_URL  = "http://ctfd.${kubernetes_namespace_v1.ctfd.metadata[0].name}.svc.cluster.local"
    POLL_RATE = "30"
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    null_resource.configure-ctfd,
  ]
}

resource "kubernetes_deployment_v1" "ctfd_exporter" {
  metadata {
    name      = "ctfd-exporter"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name # Placed in challenge-config namespace as it has access to CTFd access token
    labels = {
      app = "ctfd-exporter"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ctfd-exporter"
      }
    }

    template {
      metadata {
        labels = {
          app = "ctfd-exporter"
        }
      }

      spec {
        container {
          name  = "ctfd-exporter"
          image = var.image_ctfd_exporter

          env {
            name = "CTFD_API"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map_v1.ctfd-access-token.metadata.0.name
                key  = "access_token"
              }
            }
          }

          env {
            name = "CTFD_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.ctfd_exporter.metadata.0.name
                key  = "CTFD_URL"
              }
            }
          }

          env {
            name = "POLL_RATE"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.ctfd_exporter.metadata.0.name
                key  = "POLL_RATE"
              }
            }
          }

          port {
            container_port = 2112
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    null_resource.configure-ctfd,
    kubernetes_secret_v1.ctfd_exporter
  ]
}

resource "kubernetes_service_v1" "ctfd_exporter" {
  metadata {
    name      = "ctfd-exporter"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name
    labels = {
      app  = "ctfd-exporter"
      role = "metrics"
    }
  }

  spec {
    selector = {
      app = "ctfd-exporter"
    }

    port {
      name        = "http"
      port        = 2112
      target_port = 2112
    }
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    kubernetes_deployment_v1.ctfd_exporter,
    kubernetes_secret_v1.ctfd_exporter
  ]
}

resource "kubernetes_manifest" "ctfd_exporter_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "ctfd-exporter"
      namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name
    }
    spec = {
      selector = {
        matchLabels = {
          app  = "ctfd-exporter"
          role = "metrics"
        }
      }
      namespaceSelector = {
        matchNames = [kubernetes_namespace_v1.challenge-config.metadata.0.name]
      }
      endpoints = [{
        port     = "http"
        interval = "30s"
      }]
    }
  }

  depends_on = [
    null_resource.configure-ctfd,
    kubernetes_deployment_v1.ctfd_exporter,
    kubernetes_service_v1.ctfd_exporter,
    kubernetes_secret_v1.ctfd_exporter
  ]
}
