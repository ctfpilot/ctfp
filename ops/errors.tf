resource "kubernetes_namespace" "errors" {
  metadata {
    name = "errors"
    labels = {
      role = "errors"
    }
  }
}

locals {
  errors_replicas = var.errors_replicas != null ? var.errors_replicas : (var.deployment_type == "single-node" ? 1 : var.deployment_type == "standard" ? 2 : 3)
}

module "errors-pull-secret" {
  source = "../tf-modules/pull-secret"

  namespace     = kubernetes_namespace.errors.metadata[0].name
  ghcr_token    = var.ghcr_token
  ghcr_username = var.ghcr_username

  depends_on = [
    kubernetes_namespace.errors
  ]
}

resource "kubernetes_deployment_v1" "errors" {
  metadata {
    name      = "errors"
    namespace = "errors"

    labels = {
      role = "errors"
    }
  }

  spec {
    replicas = local.errors_replicas

    selector {
      match_labels = {
        role = "errors"
      }
    }

    template {
      metadata {
        labels = {
          role = "errors"
        }
      }

      spec {
        enable_service_links            = false
        automount_service_account_token = false

        image_pull_secrets {
          name = var.ghcr_token != "" ? module.errors-pull-secret.pull-secret : ""
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"

          label_selector {
            match_labels = {
              role = "errors"
            }
          }
        }

        container {
          name              = "errors"
          image             = var.image_error_fallback
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.errors,
    module.errors-pull-secret
  ]
}

resource "kubernetes_service_v1" "errors" {
  metadata {
    name      = "errors"
    namespace = "errors"

    labels = {
      role = "errors"
    }
  }

  spec {
    selector = {
      role = "errors"
    }

    port {
      port        = 80
      target_port = 80
    }
  }

  depends_on = [
    kubernetes_deployment_v1.errors
  ]
}

resource "kubernetes_manifest" "traefik-errors-middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "errors"
      namespace = "errors"
    }
    spec = {
      errors = {
        status = [
          "502",
          "503",
          "504"
        ]
        query = "/{status}.html"
        service = {
          name      = "errors"
          port      = 80
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.errors,
    kubernetes_service_v1.errors
  ]
}
