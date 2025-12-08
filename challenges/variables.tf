# ------------------------
# Variables
# ------------------------

variable "kubeconfig" {
  type        = string
  description = "Base64 encoded kubeconfig file"
  sensitive   = true
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment name for the CTF"
  default     = "test"
  nullable    = false
}

variable "cluster_dns_management" {
  type        = string
  description = "The specific domain name to use for the DNS records for the management part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_management`"
  nullable    = false
}

variable "cluster_dns_ctf" {
  type        = string
  description = "The domain name to use for the DNS records for the CTF challenges part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_ctf`"
  nullable    = false
}

variable "ghcr_username" {
  description = "GitHub Container Registry username"
  type        = string
  nullable    = false
}

variable "ghcr_token" {
  description = "GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "git_token" {
  description = "GitHub repo token. Only let this token have read access to the needed repositories."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "kubectf_auth_secret" {
  type        = string
  nullable    = false
  description = "The secret to use for the authSecret in the CTF configuration"
  sensitive   = true
}

variable "kubectf_container_secret" {
  type        = string
  nullable    = false
  description = "The secret to use for the containerSecret in the CTF configuration"
  sensitive   = true
}

variable "chall_whitelist_ips" {
  type        = list(string)
  description = "List of IPs to whitelist for challenges, e.g., [ \"<ip1>\", \"<ip2>\" ]"
  default     = []
  sensitive   = true
  validation {
    condition     = length(var.chall_whitelist_ips) > 0
    error_message = "At least one IP address must be whitelisted"
  }
}

variable "challenges_static" {
  type        = map(list(string))
  description = "List of static challenges to deploy. In the format { \"<category>\" = [\"<challenge_slug1>\", \"<challenge_slug2>\"] }"
  default     = []
}

variable "challenges_shared" {
  type        = map(list(string))
  description = "List of shared challenges to deploy. In the format { \"<category>\" = [\"<challenge_slug1>\", \"<challenge_slug2>\"] }"
  default     = []
}

variable "challenges_instanced" {
  type        = map(list(string))
  description = "List of instanced challenges to deploy. In the format { \"<category>\" = [\"<challenge_slug1>\", \"<challenge_slug2>\"] }"
  default     = []
}

variable "challenges_repository" {
  type        = string
  description = "Repository URL for challenges, generated using the challenge-toolkit. See https://github.com/ctfpilot/challenge-toolkit"
  nullable    = false
}

variable "challenges_branch" {
  type        = string
  description = "Git branch for challenges. Leave empty for environment based branch (environment == prod ? main : develop)"
  default     = ""
}

variable "image_instancing_fallback" {
  type        = string
  description = "The docker image for the instancing fallback deployment. See https://github.com/ctfpilot/instancing-fallback"
  default     = "ghcr.io/ctfpilot/instancing-fallback:1.0.2"
}

variable "image_kubectf" {
  type        = string
  description = "The docker image for the kube-ctf deployment. See https://github.com/ctfpilot/kube-ctf"
  default     = "ghcr.io/ctfpilot/kube-ctf:1.0.1"
}
