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

variable "username" {
  type        = string
  description = "The username for the user"
}

variable "password" {
  type        = string
  description = "The password for the user"
  sensitive   = true
}

# ----------
# Optional
# ----------

variable "db_connection_secret_name" {
  type        = string
  description = "The name of the secret to create for the database connection"
  default     = "db-connection"
}

variable "db_connection_format" {
  type        = string
  description = "The format of the connection string"
  default     = "mysql://{{ .Username }}:{{ .Password }}@{{ .Host }}:{{ .Port }}/{{ .Database }}{{ .Params }}"
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


module "database" {
  source = "../database"

  db_name                   = var.db_name
  mariadb_cluster           = var.mariadb_cluster
  mariadb_cluster_namespace = var.mariadb_cluster_namespace
  namespace                 = var.namespace
}

module "user" {
  source = "../user"

  username                  = var.username
  password                  = var.password
  mariadb_cluster           = var.mariadb_cluster
  mariadb_cluster_namespace = var.mariadb_cluster_namespace
  namespace                 = var.namespace

  depends_on = [
    module.database
  ]
}

resource "kubernetes_manifest" "connection" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Connection"
    metadata = {
      name      = "connection"
      namespace = var.namespace
    }

    spec = {
      mariaDbRef = {
        name      = var.mariadb_cluster
        namespace = var.mariadb_cluster_namespace
      }
      username = var.username
      passwordSecretKeyRef = {
        name = "user-${var.username}"
        key  = "password"
      }
      database   = var.db_name
      secretName = var.db_connection_secret_name

      secretTemplate = {
        key         = "dsn"
        format      = var.db_connection_format
        usernameKey = "username"
        passwordKey = "password"
        hostKey     = "host"
        portKey     = "port"
        databaseKey = "database"
      }

      serviceName = var.mariadb_cluster
    }
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.replace-trigger
    ]
  }
}

resource "kubernetes_manifest" "grant" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Grant"
    metadata = {
      name      = "grant-${var.username}-${var.db_name}"
      namespace = var.namespace
    }
    spec = {
      mariaDbRef = {
        name      = var.mariadb_cluster
        namespace = var.mariadb_cluster_namespace
      }
      privileges = [
        "ALL PRIVILEGES"
      ]
      database        = var.db_name
      table           = "*"
      username        = var.username
      grantOption     = true
      host            = "%"
      cleanupPolicy   = "Delete"
      requeueInterval = "30s"
      retryInterval   = "5s"
    }
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.replace-trigger
    ]
  }
}
