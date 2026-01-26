resource "kubernetes_manifest" "ctfd-errors-middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ctfd"
      namespace = "errors"
    }
    spec = {
      errors = {
        status = [
          "500",
          "502",
          "503",
          "504"
        ]
        query = "/{status}.html"
        service = {
          name = "errors"
          port = 80
        }
      }
    }
  }
}
