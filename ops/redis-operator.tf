resource "kubernetes_namespace_v1" "redis" {
  metadata {
    name = "redis-operator"
  }
}

resource "helm_release" "redis-operator" {
  name             = "redis-operator"
  repository       = "https://ot-container-kit.github.io/helm-charts/"
  namespace        = kubernetes_namespace_v1.redis.metadata.0.name
  create_namespace = false

  chart = "redis-operator"
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
