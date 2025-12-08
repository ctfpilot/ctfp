# ----------
# Required
# ----------

variable "user_name" {
  type        = string
  description = "The name of the user to create"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy the user to"
}

variable "mariadb_cluster" {
  type        = string
  description = "The name of the MariaDB cluster to connect to"
}

variable "mariadb_cluster_namespace" {
  type        = string
  description = "The namespace of the MariaDB cluster to connect to"
}

variable "password" {
  type        = string
  description = "The password for the user"
  sensitive   = true
}

# ----------
# Resources
# ----------

resource "kubernetes_secret" "database_user_password" {
  metadata {
    name      = "user-${var.user_name}"
    namespace = var.namespace
  }

  data = {
    password = var.password
  }
}

resource "null_resource" "replace-trigger" {
  triggers = {
    "user_name"                  = var.user_name
    "namespace"                  = var.namespace
    "maria_db_cluster"           = var.mariadb_cluster
    "maria_db_cluster_namespace" = var.mariadb_cluster_namespace
  }
}


resource "kubernetes_manifest" "database_user" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "User"
    metadata = {
      name      = "${var.user_name}"
      namespace = var.namespace
    }
    spec = {
      mariaDbRef = {
        name      = var.mariadb_cluster
        namespace = var.mariadb_cluster_namespace
      }
      passwordSecretKeyRef = {
        name = kubernetes_secret.database_user_password.metadata[0].name
        key  = "password"
      }
      maxUserConnections = 2000
      host               = "%" # Allow connections from any host
    }
  }

  lifecycle {
    # Replace if any variables change
    replace_triggered_by = [
      null_resource.replace-trigger,
      kubernetes_secret.database_user_password
    ]
  }
}
