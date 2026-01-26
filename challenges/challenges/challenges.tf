variable "config_only" {
  description = "Should challenges only be deployed with config"
  type        = bool
  default     = false
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

variable "path" {
  description = "The path to the challenge"
  default     = null
}

variable "path_config" {
  description = "The path to the challenge config"
  default     = null
}

variable "argocd_project" {
  description = "The ArgoCD project to use"
  nullable    = false
}

variable "argocd_config_project" {
  description = "The ArgoCD project to use for config only challenges"
  nullable    = false
}

variable "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "challenge_namespace" {
  description = "The namespace where the challenge will be deployed"
  nullable    = false
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

variable "config_helm_only" {
  description = "Helm chart configuration for config only challenges"
  type        = bool
  default     = false
}

module "argocd-challenge" {
  source = "../challenge"

  for_each = toset(var.challenges)
  enabled  = !var.config_only

  identifier = each.value

  revision             = var.revision
  category             = var.category
  argocd_project       = var.argocd_project
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.application_repo_url
  challenge_namespace  = var.challenge_namespace
  application_name     = var.application_name
  path                 = var.path
  helm                 = var.config_helm_only ? null : var.helm
}

module "argocd-challenge-config" {
  source = "../config"

  for_each = toset(var.challenges)

  identifier = each.value

  revision             = var.revision
  category             = var.category
  argocd_project       = var.argocd_config_project
  argocd_namespace     = var.argocd_namespace
  application_repo_url = var.application_repo_url
  config_namespace     = var.config_namespace
  application_name     = var.application_name
  path                 = var.path_config
  helm                 = var.helm
}
