locals {
  argocd_project = "flight-ops"
}

module "flight-ops-project" {
  source = "../argocd/project"

  project_name = "flight-ops"
  project_destinations = [
    {
      namespace = "*"
      server    = "*"
    }
  ]
}

module "flight-ops-repo-access" {
  source = "../private-repo"

  name             = local.argocd_project
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.flight_ops_repo_url
  argocd_project   = local.argocd_project

  depends_on = [
    module.flight-ops-project
  ]
}

module "flight-ops-ground-control" {
  source = "../argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_name          = "ground-control"
  application_project       = local.argocd_project
  application_namespace     = local.groundcontrol_namespace
  application_repo_url      = var.flight_ops_repo_url
  application_repo_path     = var.ground_control_repo_path
  application_repo_revision = var.flight_ops_repo_revision

  depends_on = [
    kubernetes_namespace_v1.groundcontrol,
    module.flight-ops-project,
    module.flight-ops-repo-access,
  ]
}

module "redis" {
  source = "../redis/replication"

  namespace        = local.dispatcher_namespace
  redis_password   = var.dispatcher_redis_password
  replication_size = var.dispatcher_redis_replicas

  depends_on = [
    kubernetes_namespace_v1.dispatcher,
  ]
}

resource "kubernetes_secret_v1" "dispatcher_secret" {
  metadata {
    name      = "dispatcher-secrets"
    namespace = local.dispatcher_namespace
  }

  data = {
    "jwt-secret"    = var.management_auth_secret
    "server-secret" = var.container_secret
  }

  depends_on = [
    kubernetes_namespace_v1.dispatcher,
  ]
}

module "flight-ops-dispatcher" {
  source = "../argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_name          = "dispatcher"
  application_project       = local.argocd_project
  application_namespace     = local.dispatcher_namespace
  application_repo_url      = var.flight_ops_repo_url
  application_repo_path     = var.dispatcher_repo_path
  application_repo_revision = var.flight_ops_repo_revision

  helm = {
    values = yamlencode({
      dispatcher = {
        replicas = 20
        maxConcurrentFlights = var.max_instances
        flightDomain         = "challs.${var.challenge_dns}"
        serverSecret = {
          existingSecret = kubernetes_secret_v1.dispatcher_secret.metadata[0].name
          key            = "server-secret"
        }
        jwt = {
          issuers = var.dispatcher_jwt_issuers
          secret = {
            existingSecret = kubernetes_secret_v1.dispatcher_secret.metadata[0].name
            key            = "jwt-secret"
          }
        }
        redis = {
          address = "redis-replication-master.${local.dispatcher_namespace}.svc.cluster.local:6379"
          password = {
            existingSecret = "redis-secret"
            key            = "password"
          }
        }
      }
    })
  }

  depends_on = [
    kubernetes_namespace_v1.dispatcher,
    module.flight-ops-project,
    module.flight-ops-repo-access,
    module.redis,
    kubernetes_secret_v1.dispatcher_secret,
  ]
}

locals {
  management_dns = "chall-manager.${var.management_dns}"
}

resource "kubernetes_ingress_v1" "challenge-manager" {
  metadata {
    name      = "challenge-manager"
    namespace = local.dispatcher_namespace

    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops-challenge-manager-ingress"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "challenge-manager"

      "flight-ops.${var.org_name}/service" = "challenge-manager"
    }

    annotations = {
      "cert-manager.io/cluster-issuer"                   = var.cert_manager
      "traefik.ingress.kubernetes.io/router.priority"    = "10"
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
              name = "dispatcher-flight-ops-dispatcher"
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
    module.flight-ops-dispatcher,
  ]
}

output "challenge_manager_host" {
  value = local.management_dns
}
