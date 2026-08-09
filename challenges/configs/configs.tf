variable "ctf" {
  description = "The CTF to deploy"
  type        = string
  nullable    = false
}

variable "revision" {
  description = "The revision of the repository to use"
  default     = "main"
  nullable    = false
}

variable "category" {
  description = "The category of the challenge"
}

variable "challenges" {
  description = "The challenges to deploy in a given category"
  type        = list(string)
  default     = []
}

variable "path_config" {
  description = "The path to the challenge config"
  default     = null
}

variable "argocd_project" {
  description = "The ArgoCD project to use"
  nullable    = false
}

variable "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "config_namespace" {
  description = "The namespace where the challenge config will be deployed"
  nullable    = false
}

variable "application_name" {
  description = "The name of the application"
  default     = null
}

variable "application_repo_url" {
  description = "The URL of the repository where the application manifests are stored"
  nullable    = false
}

variable "helm" {
  description = "Helm chart configuration"
  type        = any
  default     = null
}

module "argocd-challenge-config" {
  source = "../config"

  for_each = toset(var.challenges)

  identifier = each.value

  ctf                  = var.ctf
  revision             = var.revision
  category             = var.category
  argocd_project       = var.argocd_project
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.application_repo_url
  config_namespace     = var.config_namespace
  application_name     = var.application_name
  path                 = var.path_config
  helm                 = var.helm
}
