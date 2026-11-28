# Apply only the CTFPilot labels so existing namespace labels survive upgrades.
resource "kubernetes_labels" "namespaces" {
  for_each = {
    ctfd           = kubernetes_namespace_v1.ctfd.metadata[0].name
    mariadb        = kubernetes_namespace_v1.db.metadata[0].name
    "ctfd-manager" = kubernetes_namespace_v1.challenge-config.metadata[0].name
  }

  api_version   = "v1"
  kind          = "Namespace"
  field_manager = "ctfpilot-platform"

  metadata {
    name = each.value
  }

  labels = {
    "app.kubernetes.io/name"      = each.key
    "app.kubernetes.io/component" = "platform"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "platform"
  }
}
