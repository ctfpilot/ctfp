resource "kubernetes_secret_v1" "mariadb-cluster" {
  metadata {
    name      = "db-cluster-${var.cluster_name}"
    namespace = var.namespace
  }

  data = {
    "root-password" = var.root_password
  }
}
