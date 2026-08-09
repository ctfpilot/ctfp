locals {
  ctfd_name = "ctfd-${var.ctf_slug}"
}

resource "kubernetes_namespace_v1" "ctfd" {
  metadata {
    name = local.ctfd_name
  }
}

module "ctfd-repo-access" {
  source = "../private-repo"

  name             = local.ctfd_name
  argocd_namespace = var.argocd_namespace
  ghcr_username    = var.ghcr_username
  git_token        = var.git_token
  git_repo         = var.ctfd_k8s_deployment_repository
  argocd_project   = local.ctfd_name

  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

module "ctfd-pull-secret" {
  source = "../pull-secret"

  namespace     = kubernetes_namespace_v1.ctfd.metadata.0.name
  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token


  depends_on = [
    kubernetes_namespace_v1.ctfd
  ]
}

module "redis" {
  source = "../redis/replication"

  namespace        = kubernetes_namespace_v1.ctfd.metadata.0.name
  redis_password   = var.ctfd_redis_password
  replication_size = var.ctfd_redis_replicas

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
    "url"             = "redis://:${var.ctfd_redis_password}@redis-replication-master.${kubernetes_namespace_v1.ctfd.metadata.0.name}.svc.cluster.local:6379/0"
    "cluster_enabled" = "0"
    "cluster"         = null
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
    "host"   = "https://${var.kubectf_host}"
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
    "url"     = var.ctfd_plugin_first_blood_url
    "limit"   = "1"
    "message" = var.ctfd_plugin_first_blood_message
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
                  ctfd: "${var.ctf_slug}"
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
                  ctfd: "${var.ctf_slug}"
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
                  ctfd: "${var.ctf_slug}"
                  file: "registrations.log"

      output.elasticsearch:
        hosts: ["https://${var.filebeat_elasticsearch_host}:443"]
        username: "${var.filebeat_elasticsearch_username}"
        password: "${var.filebeat_elasticsearch_password}"
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
  source = "../argocd/project"

  argocd_namespace = var.argocd_namespace
  project_name     = local.ctfd_name
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
  source = "../argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_namespace     = kubernetes_namespace_v1.ctfd.metadata.0.name
  application_name          = local.ctfd_name
  application_repo_url      = var.ctfd_k8s_deployment_repository
  application_repo_path     = var.ctfd_k8s_deployment_path
  application_repo_revision = var.ctfd_k8s_deployment_branch
  application_project       = local.ctfd_name
  argocd_finalizers         = []
  helm = {

  }

  depends_on = [
    kubernetes_namespace_v1.ctfd,
    module.database,
    module.redis,
    kubernetes_secret_v1.ctfd-redis-connection
  ]
}

module "ctfd-ingress" {
  source = "../kubernetes/ingress"

  namespace          = kubernetes_namespace_v1.ctfd.metadata.0.name
  service_name       = local.ctfd_name
  ingress_name       = "ctfd-ingress"
  hostname           = var.ctf_url
  traefik_middleware = "errors-ctfd@kubernetescrd"

  depends_on = [
    kubernetes_namespace_v1.ctfd,
  ]
}
