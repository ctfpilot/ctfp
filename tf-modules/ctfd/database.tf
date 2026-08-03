module "database" {
  source = "../mariadb/database-user"

  db_name                   = "ctfd-db-${var.ctf_slug}"
  username                  = var.db_user
  password                  = var.db_password
  mariadb_cluster           = var.db_cluster_name
  mariadb_cluster_namespace = var.db_cluster_namespace
  namespace                 = kubernetes_namespace_v1.ctfd.metadata.0.name
  db_connection_secret_name = "ctfd-db-connection"
  db_connection_format      = "mysql+pymysql://{{ .Username }}:{{ .Password }}@{{ .Host }}:{{ .Port }}/{{ .Database }}{{ .Params }}"
}