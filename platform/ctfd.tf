locals {
  ctfd_k8s_deployment_branch = var.ctfd_k8s_deployment_branch == "" ? local.env_branch : var.ctfd_k8s_deployment_branch
}


resource "kubernetes_namespace_v1" "ctfd" {
  metadata {
    name = "ctfd"
  }
}

resource "kubernetes_namespace_v1" "db" {
  metadata {
    name = "db"
  }
}


module "ctfd-repo-access" {
  source = "../tf-modules/private-repo"

  name             = "ctfd"
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.ctfd_k8s_deployment_repository
  argocd_project   = "ctfd"

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

module "ctfd-pull-secret" {
  source = "../tf-modules/pull-secret"

  namespace     = kubernetes_namespace_v1.ctfd.metadata.0.name
  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token


  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

locals {
  db_name = "ctfd-db"
}

module "db-cluster" {
  source = "../tf-modules/mariadb-cluster"

  namespace     = kubernetes_namespace_v1.db.metadata.0.name
  cluster_name  = local.db_name
  root_password = var.db_root_password

  s3_bucket     = var.s3_bucket
  s3_region     = var.s3_region
  s3_endpoint   = var.s3_endpoint
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key

  mariadb_version = var.mariadb_version

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

module "database" {
  source = "../tf-modules/database/database-user"

  db_name                   = var.db_user
  password                  = var.db_password
  mariadb_cluster           = local.db_name
  mariadb_cluster_namespace = kubernetes_namespace_v1.db.metadata.0.name
  namespace                 = kubernetes_namespace_v1.ctfd.metadata.0.name
  db_connection_secret_name = "${local.db_name}-connection"
  db_connection_format      = "mysql+pymysql://{{ .Username }}:{{ .Password }}@{{ .Host }}:{{ .Port }}/{{ .Database }}{{ .Params }}"

  depends_on = [
    module.db-cluster
  ]
}

locals {
  redis_password = ""
}

module "redis" {
  source = "../tf-modules/redis"

  namespace      = kubernetes_namespace_v1.ctfd.metadata.0.name
  redis_password = local.redis_password

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "ctfd-redis-connection" {
  metadata {
    name      = "ctfd-redis-connection"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "url"             = ""
    "cluster_enabled" = "1"
    "cluster"         = "redis-cluster-leader:6379,redis-cluster-leader-additional:6379,redis-cluster-master:6379"
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "kube-ctf" {
  metadata {
    name      = "kube-ctf-config"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "host"   = "https://manager.${var.cluster_dns_management}"
    "secret" = var.kubectf_auth_secret
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "ctfd" {
  metadata {
    name      = "ctfd-secret"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "secret_key" = var.ctfd_secret_key
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "ctfd-discord-webhook" {
  metadata {
    name      = "ctfd-discord-webhook"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "url"     = var.ctfd_plugin_first_blood_limit_url
    "limit"   = "1"
    "message" = ":drop_of_blood: First blood for **{challenge}** goes to **{user}**! :drop_of_blood:"
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "ctfd-s3-credentials" {
  metadata {
    name      = "ctfd-s3-credentials"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "bucket"        = var.ctf_s3_bucket
    "region"        = var.ctf_s3_region
    "endpoint"      = var.ctf_s3_endpoint
    "access_key"    = var.ctf_s3_access_key
    "secret_key"    = var.ctf_s3_secret_key
    "custom_prefix" = var.ctf_s3_prefix
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

resource "kubernetes_secret_v1" "ctfd-filebeat-config" {
  metadata {
    name      = "ctfd-filebeat-config"
    namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
  }

  data = {
    "filebeat.yml" = <<-EOF
      filebeat.inputs:
        - type: filestream
          id: submissions
          enabled: true
          paths:
            - /opt/CTFd/CTFd/logs/submissions.log
          processors:
            - add_fields:
                target: ''
                fields:
                  cluster: "${var.cluster_dns_management}"
                  application: "ctfd"
                  file: "submissions.log"
        - type: filestream
          id: logins
          enabled: true
          paths:
            - /opt/CTFd/CTFd/logs/logins.log
          processors:
            - add_fields:
                target: ''
                fields:
                  cluster: "${var.cluster_dns_management}"
                  application: "ctfd"
                  file: "logins.log"
        - type: filestream
          id: registrations
          enabled: true
          paths:
            - /opt/CTFd/CTFd/logs/registrations.log
          processors:
            - add_fields:
                target: ''
                fields:
                  cluster: "${var.cluster_dns_management}"
                  application: "ctfd"
                  file: "registrations.log"

      output.elasticsearch:
        hosts: ["https://${var.fluentd_elasticsearch_host}:443"]
        username: "${var.fluentd_elasticsearch_username}"
        password: "${var.fluentd_elasticsearch_password}"
        protocol: https
        ssl.verification_mode: "full"
        index: filebeat-${var.environment}-ctfd

      setup:
        template:
          name: "filebeat-${var.environment}-ctfd"
          pattern: "filebeat-${var.environment}-ctfd*"
          overwrite: false
        ilm:
          enabled: true
          policy_name: "filebeat"
    EOF
  }

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]

}

module "argocd-project" {
  source = "../tf-modules/argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = "ctfd"
  project_destinations = [
    {
      namespace = kubernetes_namespace_v1.ctfd.metadata.0.name
      server    = "*"
    }
  ]

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

module "argocd-ctfd" {
  source = "../tf-modules/argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_namespace     = kubernetes_namespace_v1.ctfd.metadata.0.name
  application_name          = "ctfd"
  application_repo_url      = var.ctfd_k8s_deployment_repository
  application_repo_path     = var.ctfd_k8s_deployment_path
  application_repo_revision = local.ctfd_k8s_deployment_branch
  application_project       = "ctfd"
  argocd_finalizers         = []

  depends_on = [
    kubernetes_namespace_v1.ctfd,
    module.database,
    module.redis,
    kubernetes_secret_v1.ctfd-redis-connection
  ]
}

module "ctfd-ingress" {
  source = "../tf-modules/kubernetes/ingress"

  namespace          = kubernetes_namespace_v1.ctfd.metadata.0.name
  service_name       = "ctfd"
  ingress_name       = "ctfd-ingress"
  hostname           = var.cluster_dns_platform
  traefik_middleware = "errors-ctfd@kubernetescrd"

  depends_on = [
    kubernetes_namespace_v1.ctfd,
    kubernetes_manifest.ctfd-errors-middleware
  ]
}
