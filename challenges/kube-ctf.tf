module "kube_ctf" {
  source = "../tf-modules/flight-ops"

  argocd_namespace         = var.argocd_namespace
  flight_ops_repo_url      = var.flight_ops_repo_url
  ground_control_repo_path = var.ground_control_repo_path
  dispatcher_repo_path     = var.dispatcher_repo_path
  flight_ops_repo_revision = var.flight_ops_repo_revision != "" ? var.flight_ops_repo_revision : (var.environment == "prod" ? "main" : "develop")

  dispatcher_jwt_issuers    = [for ctf in var.ctfs : "ctfd-${ctf.slug}"]
  dispatcher_redis_password = var.dispatcher_redis_password
  dispatcher_redis_replicas = 1

  challenge_dns  = var.cluster_dns_ctf
  management_dns = var.cluster_dns_management

  org_name     = "ctfpilot.com"
  cert_manager = "cert-manager-global"

  management_auth_secret = var.kubectf_auth_secret
  container_secret       = var.kubectf_container_secret

  image_landing           = var.image_instancing_fallback
  image_challenge_manager = var.image_kubectf
  registry_prefix         = "docker.io" # Optional, used in rendering templates

  ghcr_username = var.ghcr_username
  git_token     = var.git_token
  ghcr_token    = var.ghcr_token

  max_instances = 6
}

output "Hosts" {
  value = {
    "Challenges" = module.kube_ctf.challenge_host
    "Management" = module.kube_ctf.challenge_manager_host
  }
}
