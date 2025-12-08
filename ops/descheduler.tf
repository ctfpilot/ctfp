resource "kubernetes_namespace_v1" "descheduler" {
  metadata {
    name = "descheduler"
  }
}

resource "helm_release" "descheduler" {
  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler/descheduler"
  version    = var.descheduler_version

  namespace        = kubernetes_namespace_v1.descheduler.metadata.0.name
  create_namespace = false

  values = [
    yamlencode({
      serviceMonitor = {
        enabled   = true
        namespace = "prometheus"
      }
    })
  ]
}
