locals {
  ctfs_map = {
    for item in var.ctfs : item.slug => item
  }
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
  ctf_manager_namespace      = nonsensitive("challenge-config-${local.ctfs_map[each.key].slug}")
  ctf_manager_url            = nonsensitive("manager.${local.ctfs_map[each.key].slug}.${var.cluster_dns_management}")
  ctfd_manager_password      = var.ctfd_manager_password
  ctfd_manager_github_repo   = var.ctfd_manager_github_repo
  ctfd_manager_github_branch = var.ctfd_manager_github_branch
  image_ctfd_manager         = var.image_ctfd_manager

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
