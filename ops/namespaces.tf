# Apply only the CTFPilot labels so existing namespace labels survive upgrades.
resource "kubernetes_labels" "namespaces" {
  for_each = {
    argocd             = kubernetes_namespace_v1.argocd.metadata[0].name
    "cert-manager"     = kubernetes_namespace_v1.cert_manager.metadata[0].name
    descheduler        = kubernetes_namespace_v1.descheduler.metadata[0].name
    filebeat           = kubernetes_namespace.logging-namespace.metadata[0].name
    "mariadb-operator" = kubernetes_namespace_v1.mariadb.metadata[0].name
    "prod-default-web" = kubernetes_namespace.prod-default-web.metadata[0].name
    prometheus         = kubernetes_namespace_v1.prometheus.metadata[0].name
    "redis-operator"   = kubernetes_namespace_v1.redis.metadata[0].name
  }

  api_version   = "v1"
  kind          = "Namespace"
  field_manager = "ctfpilot-ops"

  metadata {
    name = each.value
  }

  labels = {
    "app.kubernetes.io/name"      = each.key
    "app.kubernetes.io/component" = "ops"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "ops"
  }
}
