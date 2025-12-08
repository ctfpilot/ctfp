locals {
  ctfd_manager_gh_branch = var.ctfd_manager_github_branch == "" ? local.env_branch : var.ctfd_manager_github_branch
}

resource "kubernetes_namespace_v1" "challenge-config" {
  metadata {
    name = "challenge-config"
  }
}

module "ctfd-manager-pull-secret" {
  source = "../tf-modules/pull-secret"

  namespace     = kubernetes_namespace_v1.challenge-config.metadata.0.name
  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token


  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_service_account_v1" "ctfd-manager" {
  metadata {
    name      = "ctfd-manager"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_role_v1" "ctfd-manager" {
  metadata {
    name      = "ctfd-manager"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
}

resource "kubernetes_role_binding_v1" "ctfd-manager" {
  metadata {
    name      = "ctfd-manager"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.ctfd-manager.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ctfd-manager.metadata.0.name
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    kubernetes_service_account_v1.ctfd-manager,
    kubernetes_role_v1.ctfd-manager
  ]
}

resource "kubernetes_secret_v1" "ctfd-manager-secret" {
  metadata {
    name      = "ctfd-manager-secret"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  data = {
    "github-token" = var.git_token
    "password"     = var.ctfd_manager_password
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_config_map_v1" "ctfd-access-token" {
  metadata {
    name      = "ctfd-access-token"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  lifecycle {
    ignore_changes = [
      data # This will be updated by the CTFd Manager
    ]
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_config_map_v1" "ctfd-challenges" {
  metadata {
    name      = "ctfd-challenges"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  lifecycle {
    ignore_changes = [
      data # This will be updated by the CTFd Manager
    ]
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_config_map_v1" "ctfd-pages" {
  metadata {
    name      = "ctfd-pages"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  lifecycle {
    ignore_changes = [
      data # This will be updated by the CTFd Manager
    ]
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]

}

resource "kubernetes_config_map_v1" "challenge-configmap-hashset" {
  metadata {
    name      = "challenge-configmap-hashset"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  lifecycle {
    ignore_changes = [
      data # This will be updated by the CTFd Manager
    ]
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_config_map_v1" "mapping-map" {
  metadata {
    name      = "mapping-map"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  data = {
    "categories" = jsonencode({
      "web"        = "Web"
      "forensics"  = "Forensics"
      "rev"        = "Reverse Engineering"
      "crypto"     = "Crypto"
      "pwn"        = "Pwn"
      "boot2root"  = "Boot2Root"
      "osint"      = "OSINT"
      "misc"       = "Misc"
      "blockchain" = "Blockchain"
      "mobile"     = "Mobile",
    }),
    "difficulties" = jsonencode({
      "beginner"    = "Beginner"
      "easy"        = "Easy"
      "easy-medium" = "Easy - Medium"
      "medium"      = "Medium"
      "medium-hard" = "Medium - Hard"
      "hard"        = "Hard"
      "very-hard"   = "Very Hard"
      "insane"      = "Insane"
    }),
    "difficulty-categories" = jsonencode({
      "beginner" = "Beginner"
    })
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config
  ]
}

resource "kubernetes_deployment_v1" "ctfd-manager" {
  metadata {
    name      = "ctfd-manager"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "ctfd-manager"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          app = "ctfd-manager"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.ctfd-manager.metadata.0.name
        image_pull_secrets {
          name = "dockerconfigjson-github-com"
        }

        container {
          name  = "ctfd-manager"
          image = var.image_ctfd_manager

          env {
            name  = "NAMESPACE"
            value = "challenge-config"
          }

          env {
            name  = "GITHUB_REPO"
            value = var.ctfd_manager_github_repo
          }

          env {
            name  = "GITHUB_BRANCH"
            value = local.ctfd_manager_gh_branch
          }

          env {
            name = "GITHUB_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.ctfd-manager-secret.metadata.0.name
                key  = "github-token"
              }
            }
          }

          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.ctfd-manager-secret.metadata.0.name
                key  = "password"
              }
            }
          }

          env {
            name  = "CTFD_URL"
            value = "https://${var.cluster_dns_platform}"
          }

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "30Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/api/status"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
          }

          liveness_probe {
            http_get {
              path = "/api/status"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    kubernetes_service_account_v1.ctfd-manager,
    kubernetes_secret_v1.ctfd-manager-secret,
    kubernetes_config_map_v1.ctfd-access-token,
    kubernetes_config_map_v1.ctfd-challenges,
    kubernetes_config_map_v1.mapping-map,
    module.ctfd-manager-pull-secret
  ]

  // Force redeployment if categories map changes
  lifecycle {
    replace_triggered_by = [
      kubernetes_config_map_v1.mapping-map.data
    ]
  }
}

resource "kubernetes_service_v1" "ctfd-manager" {
  metadata {
    name      = "ctfd-manager"
    namespace = kubernetes_namespace_v1.challenge-config.metadata.0.name

    labels = {
      system = "ctfpilot"
      app    = "ctfd-manager"
    }
  }

  spec {
    selector = {
      app = "ctfd-manager"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment_v1.ctfd-manager
  ]
}

module "ctfd-manager-ingress" {
  source = "../tf-modules/kubernetes/ingress"

  namespace    = kubernetes_namespace_v1.challenge-config.metadata.0.name
  service_name = kubernetes_service_v1.ctfd-manager.metadata.0.name
  hostname     = "ctfd-manager.${var.cluster_dns_management}"

  depends_on = [
    kubernetes_namespace_v1.challenge-config,
    kubernetes_service_v1.ctfd-manager
  ]
}
