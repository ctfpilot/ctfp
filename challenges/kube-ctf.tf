module "kube_ctf" {
  source = "../tf-modules/kubectf"

  challenge_dns  = var.cluster_dns_ctf
  management_dns = var.cluster_dns_ctf

  org_name     = "io"
  cert_manager = "cert-manager-global"

  management_auth_secret = var.kubectf_auth_secret
  container_secret       = var.kubectf_container_secret

  image_landing           = var.image_instancing_fallback
  image_challenge_manager = var.image_kubectf
  registry_prefix         = "docker.io" # Optional, used in rendering templates

  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token

  max_instances = 6
}

output "Hosts" {
  value = {
    "Challenges" = module.kube_ctf.challenge_host
    "Management" = module.kube_ctf.challenge_manager_host
  }
}
