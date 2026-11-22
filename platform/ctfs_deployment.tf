locals {
  ctfs_map = {
    for item in var.ctfs : item.slug => item
  }
  uses_root_dns = anytrue([for ctf in var.ctfs : ctf.subdomain == ""])
}

module "ctfd_instance" {
  source = "../tf-modules/ctfd"

  for_each = nonsensitive(toset(keys(local.ctfs_map)))

  # Environment configuration
  environment            = nonsensitive(var.environment)
  cluster_dns_management = nonsensitive(var.cluster_dns_management)
  ghcr_username          = nonsensitive(var.ghcr_username)
  ghcr_token             = var.ghcr_token
  git_token              = var.git_token
  argocd_namespace       = nonsensitive(var.argocd_namespace)

  # CTF variables
  ctf_slug                    = nonsensitive(local.ctfs_map[each.key].slug)
  ctf_url                     = nonsensitive(local.ctfs_map[each.key].subdomain != "" ? "${local.ctfs_map[each.key].subdomain}.${var.cluster_dns_platform}" : "${var.cluster_dns_platform}")
  ctf_name                    = nonsensitive(local.ctfs_map[each.key].name)
  ctf_description             = nonsensitive(local.ctfs_map[each.key].description)
  ctf_start_time              = nonsensitive(local.ctfs_map[each.key].start_time)
  ctf_end_time                = nonsensitive(local.ctfs_map[each.key].end_time)
  ctf_user_mode               = nonsensitive(local.ctfs_map[each.key].user_mode)
  ctf_challenge_visibility    = nonsensitive(local.ctfs_map[each.key].challenge_visibility)
  ctf_account_visibility      = nonsensitive(local.ctfs_map[each.key].account_visibility)
  ctf_score_visibility        = nonsensitive(local.ctfs_map[each.key].score_visibility)
  ctf_registration_visibility = nonsensitive(local.ctfs_map[each.key].registration_visibility)
  ctf_verify_emails           = nonsensitive(local.ctfs_map[each.key].verify_emails)
  ctf_team_size               = nonsensitive(local.ctfs_map[each.key].team_size)
  ctf_brackets                = nonsensitive(local.ctfs_map[each.key].brackets)
  ctf_theme                   = nonsensitive(local.ctfs_map[each.key].theme)
  ctf_admin_name              = nonsensitive(local.ctfs_map[each.key].admin.name)
  ctf_admin_email             = local.ctfs_map[each.key].admin.email
  ctf_admin_password          = local.ctfs_map[each.key].admin.password
  ctf_registration_code       = local.ctfs_map[each.key].registration_code
  ctf_logo_path               = nonsensitive(local.ctfs_map[each.key].logo_path)

  # CTF Mail configuration
  ctf_mail_server   = nonsensitive(local.ctfs_map[each.key].mail.host != null ? local.ctfs_map[each.key].mail.host : var.ctf_mail_server)
  ctf_mail_port     = nonsensitive(local.ctfs_map[each.key].mail.port != null ? local.ctfs_map[each.key].mail.port : var.ctf_mail_port)
  ctf_mail_tls      = nonsensitive(local.ctfs_map[each.key].mail.tls != null ? local.ctfs_map[each.key].mail.tls : var.ctf_mail_tls)
  ctf_mail_username = local.ctfs_map[each.key].mail.username != null ? local.ctfs_map[each.key].mail.username : var.ctf_mail_username
  ctf_mail_password = local.ctfs_map[each.key].mail.password != null ? local.ctfs_map[each.key].mail.password : var.ctf_mail_password
  ctf_mail_from     = nonsensitive(local.ctfs_map[each.key].mail.from != null ? local.ctfs_map[each.key].mail.from : var.ctf_mail_from)

  # CTF Plugins configuration
  kubectf_auth_secret             = local.ctfs_map[each.key].plugins.kubectf_auth_secret != null ? local.ctfs_map[each.key].plugins.kubectf_auth_secret : var.kubectf_auth_secret
  kubectf_host                    = local.ctfs_map[each.key].plugins.kubectf_host != null ? local.ctfs_map[each.key].plugins.kubectf_host : var.kubectf_host != null ? var.kubectf_host : nonsensitive("chall-manager.${var.cluster_dns_management}")
  ctfd_plugin_first_blood_url     = local.ctfs_map[each.key].plugins.first_blood_url != null ? local.ctfs_map[each.key].plugins.first_blood_url : var.ctfd_plugin_first_blood_url
  ctfd_plugin_first_blood_message = nonsensitive(local.ctfs_map[each.key].plugins.first_blood_message != null ? local.ctfs_map[each.key].plugins.first_blood_message : var.ctfd_plugin_first_blood_message)
  ctfd_plugin_first_blood_limit   = nonsensitive(local.ctfs_map[each.key].plugins.first_blood_limit != null ? local.ctfs_map[each.key].plugins.first_blood_limit : var.ctfd_plugin_first_blood_limit)

  # CTFd configuration
  ctfd_secret_key   = local.ctfs_map[each.key].ctfd.secret_key
  ctf_s3_bucket     = var.ctf_s3_bucket
  ctf_s3_region     = var.ctf_s3_region
  ctf_s3_endpoint   = var.ctf_s3_endpoint
  ctf_s3_access_key = var.ctf_s3_access_key
  ctf_s3_secret_key = var.ctf_s3_secret_key

  # CTFd deployment
  ctf_s3_prefix                  = nonsensitive(local.ctfs_map[each.key].ctfd.s3_prefix != null ? local.ctfs_map[each.key].ctfd.s3_prefix : local.ctfs_map[each.key].slug)
  ctfd_k8s_deployment_repository = nonsensitive(local.ctfs_map[each.key].ctfd.k8s_deployment_repository != null ? local.ctfs_map[each.key].ctfd.k8s_deployment_repository : var.ctfd_k8s_deployment_repository)
  ctfd_k8s_deployment_path       = nonsensitive(local.ctfs_map[each.key].ctfd.k8s_deployment_path != null ? local.ctfs_map[each.key].ctfd.k8s_deployment_path : var.ctfd_k8s_deployment_path)
  ctfd_k8s_deployment_branch     = nonsensitive(local.ctfs_map[each.key].ctfd.k8s_deployment_branch != null ? local.ctfs_map[each.key].ctfd.k8s_deployment_branch : local.ctfd_k8s_deployment_branch)

  # CTFd Manager
  ctf_manager_namespace         = nonsensitive("challenge-config-${local.ctfs_map[each.key].slug}")
  ctf_manager_url               = nonsensitive("ctfd-manager.${local.ctfs_map[each.key].slug}.${var.cluster_dns_management}")
  ctfd_manager_password         = var.ctfd_manager_password
  ctfd_manager_github_repo      = var.ctfd_manager_github_repo
  ctfd_manager_github_branch    = var.ctfd_manager_github_branch == "" ? local.env_branch : var.ctfd_manager_github_branch
  image_ctfd_manager            = var.image_ctfd_manager
  challenges_default_decay      = nonsensitive(local.ctfs_map[each.key].challenges.config.default_decay != null ? local.ctfs_map[each.key].challenges.config.default_decay : var.challenges_default_decay)
  challenges_default_points     = nonsensitive(local.ctfs_map[each.key].challenges.config.default_points != null ? local.ctfs_map[each.key].challenges.config.default_points : var.challenges_default_points)
  challenges_default_min_points = nonsensitive(local.ctfs_map[each.key].challenges.config.default_min_points != null ? local.ctfs_map[each.key].challenges.config.default_min_points : var.challenges_default_min_points)

  # Pages configuration
  pages            = nonsensitive(local.ctfs_map[each.key].pages.pages)
  pages_repository = nonsensitive(local.ctfs_map[each.key].pages.repository != null ? local.ctfs_map[each.key].pages.repository : var.pages_repository)
  pages_branch     = local.pages_branch

  # Filebeat configuration
  filebeat_elasticsearch_host     = var.filebeat_elasticsearch_host
  filebeat_elasticsearch_username = var.filebeat_elasticsearch_username
  filebeat_elasticsearch_password = var.filebeat_elasticsearch_password

  # DB configuration
  db_cluster_name      = local.db_cluster_name
  db_cluster_namespace = local.db_cluster_namespace
  db_user              = local.ctfs_map[each.key].db.user
  db_password          = local.ctfs_map[each.key].db.password

  # Redis configuration
  ctfd_redis_password = local.ctfs_map[each.key].redis.password
  ctfd_redis_replicas = local.ctfd_redis_replication_size

  depends_on = [
    module.db-cluster
  ]
}

// Forward the root DNS to the first CTF if no CTFs are using the root DNS.
resource "kubernetes_manifest" "ctf_dns_forwarding" {
  count = local.uses_root_dns ? 0 : 1

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "ctf-dns-forwarding"
      namespace = "errors"
    }
    spec = {
      redirectRegex = {
        # Matches the entire incoming host and path
        regex = "^https?://[^/]+/(.*)"
        # Uses $1 to preserve any requested subpath on the target URL
        replacement = "https://${var.ctfs[0].subdomain}.${var.cluster_dns_platform}/$1"
        permanent   = false
      }
    }
  }
}

resource "kubernetes_ingress_v1" "ctf_dns_forwarding_ingress" {
  count = local.uses_root_dns ? 0 : 1

  metadata {
    name      = "ctf-dns-forwarding-ingress"
    namespace = "errors"

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web,websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-ctf-dns-forwarding@kubernetescrd"
      "cert-manager.io/cluster-issuer"                   = "cert-manager-global"
    }
  }

  spec {
    ingress_class_name = "traefik"
    default_backend {
      service {
        name = "errors"
        port {
          number = 80
        }
      }
    }

    rule {
      host = var.cluster_dns_platform
      http {
        path {
          path = "/"
          backend {
            service {
              name = "errors"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [
        "${var.cluster_dns_platform}"
      ]

      secret_name = "${var.cluster_dns_platform}-cert"
    }
  }

  depends_on = [
    kubernetes_manifest.ctf_dns_forwarding
  ]
}
