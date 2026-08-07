resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

locals {
  cert_manager_management_solver = {
    dns01 = {
      cloudflare = {
        email = var.email
        apiTokenSecretRef = {
          name = kubernetes_secret.cloudflare_api_key_secret.metadata.0.name
          key  = "API"
        }
      },
    },
    selector = {
      dnsZones = [
        var.cloudflare_dns_management
      ]
    }
  }

  cert_manager_platform_solver = {
    dns01 = {
      cloudflare = {
        email = var.email
        apiTokenSecretRef = {
          name = kubernetes_secret.cloudflare_api_key_secret.metadata.0.name
          key  = "API"
        }
      },
    },
    selector = {
      dnsZones = [
        var.cloudflare_dns_platform
      ]
    }
  }

  cert_manager_ctf_solver = {
    dns01 = {
      cloudflare = {
        email = var.email
        apiTokenSecretRef = {
          name = kubernetes_secret.cloudflare_api_key_secret.metadata.0.name
          key  = "API"
        }
      },
    },
    selector = {
      dnsZones = [
        var.cloudflare_dns_ctf
      ]
    }
  }

  cert_manager_solvers = [
    local.cert_manager_management_solver,
    var.cloudflare_dns_platform != var.cloudflare_dns_management ? local.cert_manager_platform_solver : null,
    var.cloudflare_dns_ctf != var.cloudflare_dns_platform ? local.cert_manager_ctf_solver : null,
  ]
}

module "cert_manager" {
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "3.2.1"

  cluster_issuer_email                   = var.email
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  chart_version                          = var.cert_manager_version

  namespace_name   = kubernetes_namespace_v1.cert_manager.metadata.0.name
  create_namespace = false

  additional_set = [
    {
      name  = "replicaCount",
      value = var.deployment_type == "ha" ? 2 : 1
    },
    {
      name  = "webhook.replicaCount",
      value = var.deployment_type == "ha" ? 3 : 1
    },
    {
      name  = "cainjector.replicaCount",
      value = var.deployment_type == "ha" ? 2 : 1
    }
  ]

  solvers = [for solver in local.cert_manager_solvers : solver if solver != null]

  depends_on = [
    kubernetes_namespace_v1.cert_manager,
    kubernetes_secret.cloudflare_api_key_secret
  ]
}

# Cloudflare api token secret
resource "kubernetes_secret" "cloudflare_api_key_secret" {
  metadata {
    name      = "cloudflare-api-key-secret"
    namespace = kubernetes_namespace_v1.cert_manager.metadata.0.name
  }

  data = {
    API = var.cloudflare_api_token
  }

  depends_on = [
    kubernetes_namespace_v1.cert_manager
  ]
}
