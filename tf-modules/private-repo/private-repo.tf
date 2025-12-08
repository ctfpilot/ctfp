resource "kubernetes_secret" "private_repo" {
  metadata {
    name      = "${var.name}-private-repo-access"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.git_repo
    password = var.git_token
    username = var.ghcr_username
    project  = var.argocd_project
  }
}
