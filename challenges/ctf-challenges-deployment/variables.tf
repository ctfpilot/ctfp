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

variable "git_token" {
  description = "GitHub repo token. Only let this token have read access to the needed repositories."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "challenges_repository" {
  type        = string
  description = "Repository URL for challenges, generated using the challenge-toolkit. See https://github.com/ctfpilot/challenge-toolkit"
  nullable    = false
}

variable "challenges_branch" {
  type        = string
  description = "Git branch for challenges."
  nullable    = false
}

variable "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "argocd_project_shared_name" {
  description = "The name of the ArgoCD project for shared challenges"
  default     = "shared-challenges"
  nullable    = false
}

variable "argocd_project_instanced_name" {
  description = "The name of the ArgoCD project for instanced challenges"
  default     = "instanced-challenges"
  nullable    = false
}

variable "challenges_shared" {
  type        = map(list(string))
  description = "List of shared challenges to deploy. In the format { \"<category>\" = [\"<challenge_slug1>\", \"<challenge_slug2>\"] }"
  default     = {}
}

variable "challenges_instanced" {
  type        = map(list(string))
  description = "List of instanced challenges to deploy. In the format { \"<category>\" = [\"<challenge_slug1>\", \"<challenge_slug2>\"] }"
  default     = {}
}

variable "kubectf_namespace_shared" {
  description = "The namespace for shared challenges for kubectf."
  type        = string
  nullable    = false
}

variable "kubectf_namespace_instanced" {
  description = "The namespace for instanced challenges for kubectf."
  type        = string
  nullable    = false
}
