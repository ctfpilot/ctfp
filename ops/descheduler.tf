resource "kubernetes_namespace_v1" "descheduler" {
  metadata {
    name = "descheduler"
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]
  }
}

resource "helm_release" "descheduler" {
  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"
  version    = var.descheduler_version

  namespace        = kubernetes_namespace_v1.descheduler.metadata.0.name
  create_namespace = false

  values = [
    yamlencode({
      commonLabels = {
        "app.kubernetes.io/component" = "ops"
        "app.kubernetes.io/part-of"   = "ctfpilot"
        "ctfpilot.com/component"      = "ops"
      }
      serviceMonitor = {
        enabled   = true
        namespace = "prometheus"
      }
    })
  ]
}
