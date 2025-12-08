resource "kubernetes_secret_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.management_namespace
  }

  data = {
    "auth"      = var.management_auth_secret
    "container" = var.container_secret
  }

  depends_on = [
    kubernetes_namespace.management
  ]
}

resource "kubernetes_cluster_role_binding_v1" "challenge-management" {
  metadata {
    name = "kubectf-challenge-manager-read-instanced-challenges"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.challenge-management.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.challenge-manager.metadata.0.name
    namespace = local.management_namespace
  }

  depends_on = [
    kubernetes_cluster_role_v1.challenge-management,
    kubernetes_service_account_v1.challenge-manager
  ]
}

resource "kubernetes_role_binding_v1" "challenge-management" {
  metadata {
    name      = "challenge-manager"
    namespace = local.instanced_challenge_namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role_v1.challenge-management.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.challenge-manager.metadata.0.name
    namespace = local.management_namespace
  }

  depends_on = [
    kubernetes_role_v1.challenge-management
  ]
}

resource "kubernetes_cluster_role_v1" "challenge-management" {
  metadata {
    name = "kubectf-read-instanced-challenges"
  }

  rule {
    api_groups = ["kube-ctf.${var.org_name}"]
    resources  = ["instanced-challenges"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_v1" "challenge-management" {
  metadata {
    name      = "challenge-manager"
    namespace = local.instanced_challenge_namespace
  }

  rule {
    api_groups = ["*"]
    resources = [
      "ingresses",
      "ingressroutes",
      "ingressroutetcps",
      "pods",
      "deployments",
      "services",
      "namespaces",
      "secrets",
      "networkpolicies"
    ]
    verbs = [
      "create",
      "delete",
      "get",
      "list",
      "patch",
      "update",
      "watch"
    ]
  }

  depends_on = [
    kubernetes_namespace.management
  ]
}

resource "kubernetes_service_account_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name
    }
  }

  depends_on = [
    kubernetes_namespace.management
  ]
}

locals {
  management_dns = "manager.${var.management_dns}"
}

resource "kubernetes_deployment_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf-challenge-manager"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "challenge-manager"

      "kube-ctf.${var.org_name}/service" = "challenge-manager"
    }
  }

  spec {
    replicas = var.services_replicas

    selector {
      match_labels = {
        "kube-ctf.${var.org_name}/service" = "challenge-manager"
      }
    }

    template {
      metadata {
        labels = {
          "kube-ctf.${var.org_name}/service" = "challenge-manager"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.challenge-manager.metadata.0.name

        image_pull_secrets {
          name = var.ghcr_token != "" ? module.pull-secret[local.management_namespace].pull-secret : ""
        }

        container {
          name              = "challenge-manager"
          image             = var.image_challenge_manager
          image_pull_policy = "Always"


          port {
            container_port = 3000
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          env {
            name  = "KUBECTF_BASE_DOMAIN"
            value = local.challenges_host
          }

          env {
            name  = "KUBECTF_API_DOMAIN"
            value = local.management_dns
          }

          env {
            name  = "KUBECTF_NAMESPACE"
            value = local.instanced_challenge_namespace
          }

          env {
            name  = "KUBECTF_MAX_OWNER_DEPLOYMENTS"
            value = var.max_instances
          }

          env {
            name  = "KUBECTF_REGISTRY_PREFIX"
            value = var.registry_prefix
          }

          env {
            name = "KUBECTF_AUTH_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.challenge-manager.metadata.0.name
                key  = "auth"
              }
            }
          }

          env {
            name = "KUBECTF_CONTAINER_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.challenge-manager.metadata.0.name
                key  = "container"
              }
            }
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "512Mi"
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
    kubernetes_service_account_v1.challenge-manager,
    kubernetes_secret_v1.challenge-manager,
    kubernetes_cluster_role_binding_v1.challenge-management,
    kubernetes_role_binding_v1.challenge-management,
    kubernetes_cluster_role_v1.challenge-management,
    kubernetes_role_v1.challenge-management,
    module.pull-secret,
    local.challenges_host
  ]
}

resource "kubernetes_service_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf-challenge-manager-service"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "challenge-manager"

      "kube-ctf.${var.org_name}/service" = "challenge-manager"
    }
  }

  spec {
    selector = {
      "kube-ctf.${var.org_name}/service" = "challenge-manager"
    }

    port {
      port = 3000
    }
  }

  depends_on = [
    kubernetes_deployment_v1.challenge-manager
  ]
}

resource "kubernetes_ingress_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf-challenge-manager-ingress"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "challenge-manager"

      "kube-ctf.${var.org_name}/service" = "challenge-manager"
    }

    annotations = {
      "cert-manager.io/cluster-issuer"                   = var.cert_manager
      "traefik.ingress.kubernetes.io/router.priority"    = "10"
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-errors@kubernetescrd"
    }
  }

  spec {
    tls {
      hosts = [
        local.management_dns
      ]

      secret_name = "kubectf-cert-challenge-manager"
    }

    rule {
      host = local.management_dns

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.challenge-manager.metadata.0.name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_v1.challenge-manager
  ]
}

output "challenge_manager_host" {
  value = local.management_dns
}
