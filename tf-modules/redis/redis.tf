variable "namespace" {
  description = "Namespace for the Redis cluster"
  type        = string
}

variable "redis_password" {
  description = "Password for the Redis cluster"
  type        = string
  sensitive   = true

}

resource "kubernetes_secret_v1" "redis_secret" {
  metadata {
    name      = "redis-secret"
    namespace = var.namespace
  }

  data = {
    "password" = var.redis_password
  }
}

resource "kubernetes_manifest" "redis-cluster" {
  manifest = yamldecode(templatefile("${path.module}/config/redis-cluster.yml", {
    namespace = var.namespace
  }))
}

resource "kubernetes_manifest" "redis-cluster-monitor" {
  manifest = yamldecode(templatefile("${path.module}/config/redis-cluster-monitor.yml", {
    namespace = var.namespace
  }))
}

# resource "kubernetes_manifest" "redis_replication" {
#   manifest = yamldecode(templatefile("${path.module}/config/redis-replication.yml", {
#     namespace = var.namespace
#   }))
# }

# resource "kubernetes_manifest" "redis_sentinel" {
#   manifest = yamldecode(templatefile("${path.module}/config/redis-sentinel.yml", {
#     namespace = var.namespace
#   }))
# }

# resource "kubernetes_manifest" "redis_sentinel_monitor" {
#   manifest = yamldecode(templatefile("${path.module}/config/redis-sentinel-monitor.yml", {
#     namespace = var.namespace
#   }))
# }

# resource "kubernetes_manifest" "redis_standalone" {
#   manifest = yamldecode(templatefile("${path.module}/config/redis-standalone.yml", {
#     namespace = var.namespace
#   }))
# }

# resource "kubernetes_manifest" "redis_standalone_monitoring" {
#   manifest = yamldecode(templatefile("${path.module}/config/redis-standalone-monitor.yml", {
#     namespace = var.namespace
#   }))
# }

