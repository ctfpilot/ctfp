resource "kubernetes_namespace_v1" "redis" {
  metadata {
    name = "redis-operator"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "helm_release" "redis-operator" {
  name             = "redis-operator"
  namespace        = kubernetes_namespace_v1.redis.metadata.0.name
  create_namespace = false

  chart   = data.external.labeled_chart["redis-operator"].result.path
  version = var.redis_operator_version

  // Force use of longhorn storage class
  # set = [{
  #   name  = "redis-operator.storageClass"
  #   value = "longhorn"
  # }]

  depends_on = [
    kubernetes_namespace_v1.redis
  ]
}
