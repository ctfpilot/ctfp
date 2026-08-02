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

locals {
  traefik_redis_cluster_size = var.traefik_redis_cluster_size != null ? var.traefik_redis_cluster_size : (var.deployment_type != "single-node" ? 3 : 1)
}

module "traefik-redis" {
  source = "../tf-modules/redis/cluster"

  namespace      = "traefik"
  redis_password = var.traefik_redis_password
  cluster_size = local.traefik_redis_cluster_size
}
