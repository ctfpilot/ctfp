resource "kubernetes_secret" "pull-secret" {
  metadata {
    name      = "dockerconfigjson-github-com"
    namespace = var.namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" = {
        "ghcr.io" = {
          "auth" = base64encode("${var.ghcr_username}:${var.ghcr_token}")
        }
      }
    })
  }
}

output "pull-secret" {
  value = kubernetes_secret.pull-secret.metadata.0.name
}
