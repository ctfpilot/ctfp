locals {
    db_cluster_name = "ctfd-d"
    db_cluster_namespace = "ctfd-db"
}

resource "kubernetes_namespace_v1" "db" {
  metadata {
    name = local.db_cluster_namespace
  }
}

module "db-cluster" {
  source = "../tf-modules/mariadb/cluster"

  namespace     = kubernetes_namespace_v1.db.metadata.0.name
  cluster_name  = local.db_cluster_name
  root_password = var.db_root_password

  s3_bucket     = var.db_s3_bucket
  s3_region     = var.db_s3_region
  s3_endpoint   = var.db_s3_endpoint
  s3_access_key = var.db_s3_access_key
  s3_secret_key = var.db_s3_secret_key

  mariadb_version = var.mariadb_version
  timezone        = var.db_timezone

  anti_affinity = var.db_anti_affinity
}
