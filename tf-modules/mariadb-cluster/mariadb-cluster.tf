locals {
  mariadb_labels = {
    "app.kubernetes.io/name"      = "mariadb"
    "app.kubernetes.io/component" = "platform"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "platform"
  }
}

resource "kubernetes_secret_v1" "mariadb-cluster" {
  metadata {
    name      = "db-cluster-${var.cluster_name}"
    namespace = var.namespace

    labels = local.mariadb_labels
  }

  data = {
    "root-password" = var.root_password
  }
}
