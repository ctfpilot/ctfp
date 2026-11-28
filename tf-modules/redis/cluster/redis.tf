locals {
  redis_labels = {
    "app.kubernetes.io/name"      = "redis"
    "app.kubernetes.io/component" = "platform"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "platform"
  }
}

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

    labels = local.redis_labels
  }

  data = {
    "password" = var.redis_password
  }
}

data "kubernetes_resources" "redis_pods" {
  api_version    = "v1"
  kind           = "Pod"
  namespace      = var.namespace
  label_selector = "app in (redis-cluster-leader,redis-cluster-follower)"
}

resource "kubernetes_manifest" "redis-cluster" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-cluster.yml", {
    labels       = jsonencode(local.redis_labels)
    namespace    = var.namespace
    cluster_size = var.cluster_size
  }))

  lifecycle {
    precondition {
      condition = alltrue([
        for pod in data.kubernetes_resources.redis_pods.objects :
        alltrue([for key, value in local.redis_labels : try(pod.metadata.labels[key], null) == value])
      ])
      error_message = "Existing Redis pods must be labeled before changing the Redis resource. Follow the Redis label upgrade in platform/README.md."
    }
  }
}

resource "kubernetes_manifest" "redis-cluster-monitor" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-cluster-monitor.yml", {
    namespace = var.namespace
  }))
}
