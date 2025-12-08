resource "htpasswd_password" "traefik_basic_auth" {
  password = var.traefik_basic_auth.password
  salt     = random_password.salt.result

  depends_on = [
    random_password.salt
  ]
}

resource "kubernetes_secret" "traefik_basic_auth" {
  metadata {
    name      = "admin-ui-basic-auth"
    namespace = var.traefik_namespace
  }

  data = {
    "auth" = "${var.traefik_basic_auth.user}:${htpasswd_password.traefik_basic_auth.apr1}"
  }

  depends_on = [
    htpasswd_password.traefik_basic_auth
  ]
}

# Traefic basic auth middleware
resource "kubernetes_manifest" "traefik_basic_auth" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = kubernetes_secret.traefik_basic_auth.metadata.0.name
      namespace = var.traefik_namespace
    }
    spec = {
      basicAuth = {
        secret = kubernetes_secret.traefik_basic_auth.metadata.0.name
      }
    }
  }

  depends_on = [
    kubernetes_secret.traefik_basic_auth
  ]
}
