resource "kubernetes_secret_v1" "s3_access" {
  metadata {
    name      = "s3-access-${var.cluster_name}"
    namespace = var.namespace
  }

  data = {
    accessKey = var.s3_access_key
    secretKey = var.s3_secret_key
  }
}

resource "kubernetes_manifest" "mariadb-cluster-backup" {
  manifest = {
    apiVersion = "k8s.mariadb.com/v1alpha1"
    kind       = "Backup"

    metadata = {
      name      = "db-backup-${var.cluster_name}"
      namespace = var.namespace
    }

    spec = {
      mariaDbRef = {
        name      = var.cluster_name
        namespace = var.namespace
      }

      maxRetention = "720h" # 30 days
      timeZone     = "Europe/Copenhagen"
      compression  = "gzip"

      schedule = {
        cron    = "*/15 * * * *" # Every 15 minutes
        suspend = false
      }

      storage = {
        s3 = {
          bucket   = var.s3_bucket
          region   = var.s3_region
          prefix   = "backups/mariadb/${var.cluster_name}"
          endpoint = var.s3_endpoint
          accessKeyIdSecretKeyRef = {
            name = "s3-access-${var.cluster_name}"
            key  = "accessKey"
          }
          secretAccessKeySecretKeyRef = {
            name = "s3-access-${var.cluster_name}"
            key  = "secretKey"
          }
          tls = {
            enabled = true
          }
        }
      }

      # args = [
      #   "--single-transaction",
      #   "--all-databases"
      # ]

      logLevel = "info"

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "1Gi"
        }
      }
    }
  }

  depends_on = [
    kubernetes_manifest.mariadb-cluster
  ]
}
