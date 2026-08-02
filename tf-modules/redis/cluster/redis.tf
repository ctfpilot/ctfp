variable "namespace" {
  description = "Namespace for the Redis cluster"
  type        = string
}

variable "redis_password" {
  description = "Password for the Redis cluster"
  type        = string
  sensitive   = true
}

variable "cluster_size" {
  description = "Number of Redis cluster nodes"
  type        = number
  default     = 3
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
  manifest = yamldecode(templatefile("${path.module}/../config/redis-cluster.yml", {
    namespace = var.namespace
    cluster_size = var.cluster_size
  }))
}

resource "kubernetes_manifest" "redis-cluster-monitor" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-cluster-monitor.yml", {
    namespace = var.namespace
  }))
}
