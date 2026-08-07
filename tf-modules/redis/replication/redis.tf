variable "namespace" {
  description = "Namespace for the Redis replication"
  type        = string
}

variable "redis_password" {
  description = "Password for the Redis replication"
  type        = string
  sensitive   = true
}

variable "replication_size" {
  description = "Number of Redis replicas"
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

resource "kubernetes_manifest" "redis-replication" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-replication.yml", {
    namespace = var.namespace
    replication_size = var.replication_size
  }))
}

resource "kubernetes_manifest" "redis-replication-monitor" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-replication-monitor.yml", {
    namespace = var.namespace
  }))
}
