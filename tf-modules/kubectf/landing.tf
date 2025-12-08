locals {
  // Combine namepsaces from two sets
  landing_namespaces = setunion(toset(local.challenge_namespaces), toset([
    kubernetes_namespace.generic.metadata.0.name
  ]))
}

resource "kubernetes_deployment_v1" "landing" {
  for_each = local.landing_namespaces

  metadata {
    name      = "landing"
    namespace = each.value

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      role = "landing"

      "app.kubernetes.io/name"      = "kube-ctf-landing-web"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "isolated-landing"
    }
  }

  spec {
    replicas = var.services_replicas

    selector {
      match_labels = {
        role = "landing"
      }
    }

    template {
      metadata {
        labels = {
          role = "landing"
        }
      }

      spec {
        enable_service_links            = false
        automount_service_account_token = false


        image_pull_secrets {
          name = var.ghcr_token != "" ? module.pull-secret[each.value].pull-secret : ""
        }

        container {
          name              = "landing"
          image             = var.image_landing
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
    kubernetes_namespace.instanced-challenges,
    module.pull-secret
  ]
}

resource "kubernetes_service_v1" "landing" {
  for_each = local.landing_namespaces

  metadata {
    name      = "landing"
    namespace = each.value

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      role = "landing"

      "app.kubernetes.io/name"      = "kube-ctf-landing-service"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "landing"
    }
  }

  spec {
    selector = {
      role = "landing"
    }

    port {
      port        = 80
      target_port = 80
    }
  }

  depends_on = [
    kubernetes_deployment_v1.landing
  ]
}

locals {
  challenges_host = "challs.${var.challenge_dns}"
}

resource "kubernetes_ingress_v1" "landing" {
  for_each = local.challenge_namespaces
  metadata {
    name      = "landing"
    namespace = each.value

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      role = "landing"

      "app.kubernetes.io/name"      = "kube-ctf-landing-ingress"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "isolated-landing"
    }

    annotations = {
      "cert-manager.io/cluster-issuer"                = var.cert_manager
      "traefik.ingress.kubernetes.io/router.priority" = "10"
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-errors@kubernetescrd"
    }
  }

  spec {
    tls {
      hosts = [
        "${local.challenges_host}",
        "*.${local.challenges_host}"
      ]

      secret_name = "kubectf-cert-challs"
    }

    rule {
      host = local.challenges_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "landing"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "*.${local.challenges_host}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "landing"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_v1.landing
  ]
}

output "challenge_host" {
  value = local.challenges_host
}
