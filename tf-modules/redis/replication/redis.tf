locals {
  redis_labels = {
    "app.kubernetes.io/name"      = "redis"
    "app.kubernetes.io/component" = "platform"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "platform"
  }
}

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
  label_selector = "app in (redis-replication,redis-replication-s)"
}

data "kubernetes_resources" "sentinel" {
  api_version    = "apps/v1"
  kind           = "StatefulSet"
  namespace      = var.namespace
  field_selector = "metadata.name=redis-replication-s"
}

resource "kubernetes_manifest" "redis-replication" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-replication.yml", {
    labels           = jsonencode(local.redis_labels)
    namespace        = var.namespace
    replication_size = var.replication_size
  }))

  lifecycle {
    precondition {
      condition = alltrue([
        for pod in data.kubernetes_resources.redis_pods.objects :
        alltrue([for key, value in local.redis_labels : try(pod.metadata.labels[key], null) == value])
      ])
      error_message = "Existing Redis pods must be labeled before changing the Redis resource. Follow the Redis label upgrade in platform/README.md."
    }

    precondition {
      condition = alltrue([
        for sentinel in data.kubernetes_resources.sentinel.objects :
        alltrue([for key, value in local.redis_labels : try(sentinel.spec.selector.matchLabels[key], null) == value])
      ])
      error_message = "The existing Redis Sentinel StatefulSet has an immutable selector. Follow the Redis label upgrade in platform/README.md before applying."
    }
  }
}

resource "kubernetes_manifest" "redis-replication-monitor" {
  manifest = yamldecode(templatefile("${path.module}/../config/redis-replication-monitor.yml", {
    namespace = var.namespace
  }))
}
