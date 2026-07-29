resource "kubernetes_manifest" "traefik_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "traefik"
      namespace = "traefik"
    }
    spec = {
      selector = {
        matchLabels = {
          app  = "traefik"
          role = "metrics"
        }
      }
      namespaceSelector = {
        matchNames = ["traefik"]
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
        }
      ]
    }
  }
}

module "traefik-redis" {
  source = "../tf-modules/redis/cluster"

  namespace      = "traefik"
  redis_password = var.traefik_redis_password
}
