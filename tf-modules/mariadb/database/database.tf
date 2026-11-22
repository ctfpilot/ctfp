# ----------
# Required
# ----------

variable "db_name" {
  type        = string
  description = "The name of the database to create"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy the database to"
}

variable "mariadb_cluster" {
  type        = string
  description = "The name of the MariaDB cluster to connect to"
}

variable "mariadb_cluster_namespace" {
  type        = string
  description = "The namespace of the MariaDB cluster to connect to"
}

# ----------
# Optional
# ----------

variable "db_character_set" {
  type        = string
  description = "The character set to use for the database"
  default     = "utf8mb4"
}

variable "db_collate" {
  type        = string
  description = "The collation to use for the database"
  default     = "utf8mb4_0900_ai_ci"
}

variable "db_cleanup_policy" {
  type        = string
  description = "The cleanup policy to use for the database - Is it deleted or retained when this resource is deleted"
  default     = "Delete"
}

variable "db_requeue_interval" {
  type        = string
  description = "The requeue interval to use for the database"
  default     = "30s"
}

variable "db_retry_interval" {
  type        = string
  description = "The retry interval to use for the database"
  default     = "5s"
}

# ----------
# Resources
# ----------

resource "null_resource" "replace-trigger" {
  triggers = {
    "db_name"                    = var.db_name
    "namespace"                  = var.namespace
    "maria_db_cluster"           = var.mariadb_cluster
    "maria_db_cluster_namespace" = var.mariadb_cluster_namespace
  }
}

resource "kubernetes_manifest" "database" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Database"
    metadata = {
      name      = "${var.db_name}"
      namespace = var.namespace
    }
    spec = {
      name = var.db_name
      mariaDbRef = {
        name      = var.mariadb_cluster
        namespace = var.mariadb_cluster_namespace
      }
      characterSet    = var.db_character_set
      collate         = var.db_collate
      cleanupPolicy   = var.db_cleanup_policy
      requeueInterval = var.db_requeue_interval
      retryInterval   = var.db_retry_interval
    }
  }

  depends_on = [
    null_resource.replace-trigger
  ]
}
