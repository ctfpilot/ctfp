resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  namespace        = kubernetes_namespace_v1.argocd.metadata.0.name
  create_namespace = false
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_version

  # Helm chart deployment can sometimes take longer than the default 5 minutes
  timeout = 800

  # If values file specified by the var.values_file input variable exists then apply the values from this file
  # else apply the default values from the chart
  values = [
    yamlencode({
      # "redis-ha" = {
      #   enabled = true
      # },
      controller = {
        replicas : 1
      },
      server = {
        replicas : 2
      },
      repoServer = {
        replicas : 2
      },
      applicationSet = {
        replicas : 2
      }
    }),
  ]

  set_sensitive = [{
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password == "" ? "" : bcrypt(var.argocd_admin_password)
    },
    {
      name  = "configs.secret.githubSecret"
      value = var.argocd_github_secret
  }]

  set = [
    {
      name  = "dex.enabled"
      value = true
    },
    {
      name  = "configs.params.server\\.insecure"
      value = true
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]
}

resource "kubernetes_ingress_v1" "argocd-ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = kubernetes_namespace_v1.argocd.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer"                   = module.cert_manager.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-errors@kubernetescrd"
    }
  }

  spec {
    default_backend {
      service {
        name = "argocd-server"
        port {
          number = 80
        }
      }
    }

    rule {
      host = "argocd.${var.cluster_dns_management}"
      http {
        path {
          backend {
            service {
              name = "argocd-server"
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
        "argocd.${var.cluster_dns_management}"
      ]

      secret_name = "argocd-cert"
    }
  }

  depends_on = [
    kubernetes_namespace_v1.argocd,
    helm_release.argocd,
    module.cert_manager,
  ]
}
