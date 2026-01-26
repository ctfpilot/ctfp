resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

module "cert_manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = var.email
  cluster_issuer_name                    = "cert-manager-global"
  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
  chart_version                          = var.cert_manager_version

  namespace_name   = kubernetes_namespace_v1.cert_manager.metadata.0.name
  create_namespace = false


  solvers = [
    {
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
    },
    {
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
    },
    {
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
  ]

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
