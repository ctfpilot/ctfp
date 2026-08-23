locals {
  // Combine namepsaces from two sets
  landing_namespaces = setunion(toset(local.challenge_namespaces), toset([
    kubernetes_namespace_v1.generic.metadata.0.name
  ]))
}

resource "kubernetes_deployment_v1" "landing" {
  for_each = local.landing_namespaces

  metadata {
    name      = "landing"
    namespace = each.value

    labels = {
      system = "flight-ops"
      org    = var.org_name

      role = "landing"

      "app.kubernetes.io/name"      = "flight-ops-landing-web"
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
              memory = "32Mi"
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
    kubernetes_namespace_v1.instanced-challenges,
    module.pull-secret
  ]
}

resource "kubernetes_service_v1" "landing" {
  for_each = local.landing_namespaces

  metadata {
    name      = "landing"
    namespace = each.value

    labels = {
      system = "flight-ops"
      org    = var.org_name

      role = "landing"

      "app.kubernetes.io/name"      = "flight-ops-landing-service"
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

resource "kubernetes_manifest" "landing" {
  for_each = local.challenge_namespaces

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "landing"
      namespace = each.value

      labels = {
        system = "flight-ops"
        org    = var.org_name

        role = "landing"

        "app.kubernetes.io/name"      = "flight-ops-landing-ingress"
        "app.kubernetes.io/instance"  = "kubectf"
        "app.kubernetes.io/component" = "isolated-landing"
      }
    }

    spec = {
      entryPoints = ["web", "websecure"]

      routes = [
        {
          match    = "Host(`${local.challenges_host}`)"
          priority = 10

          middlewares = [
            {
              name      = "errors"
              namespace = "errors"
            }
          ]

          services = [
            {
              name = "landing"
              port = 80
            }
          ]
        },
        {
          match    = "HostRegexp(`^.+\\.${local.challenges_host}$`)"
          priority = 10

          middlewares = [
            {
              name      = "errors"
              namespace = "errors"
            }
          ]

          services = [
            {
              name = "landing"
              port = 80
            }
          ]
        }
      ]

      tls = {
        secretName = "kubectf-cert-challs"
      }
    }
  }

  depends_on = [
    kubernetes_service_v1.landing
  ]
}

resource "kubernetes_manifest" "landing_certificate" {
  for_each = local.challenge_namespaces

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = "landing-cert"
      namespace = each.value
    }

    spec = {
      secretName = "kubectf-cert-challs"
      issuerRef = {
        name = var.cert_manager
        kind = "ClusterIssuer" # Or "Issuer" depending on your setup
      }
      dnsNames = [
        local.challenges_host,
        "*.${local.challenges_host}" # Ensure your issuer supports wildcard domains via DNS-01 if using regex
      ]
    }
  }
}

output "challenge_host" {
  value = local.challenges_host
}
