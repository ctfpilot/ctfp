resource "kubernetes_manifest" "traefik-errors-middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "challenge-errors"
      namespace = local.generic_namespace
    }
    spec = {
      errors = {
        status = [
          "502",
          "503",
          "504"
        ]
        query = "/{status}.html"
        service = {
          name      = "landing"
          port      = 80
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.generic,
    kubernetes_namespace.instanced-challenges,
    kubernetes_service_v1.landing
  ]
}
