variable "enabled" {
  description = "Enable or disable the challenge deployment"
  default     = true
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

variable "identifier" {
  description = "The identifier of the challenge"
}

variable "path" {
  description = "The path to the challenge"
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

variable "challenge_namespace" {
  description = "The namespace where the challenge will be deployed"
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

module "argocd-challenge" {
  source = "../../tf-modules/argocd/application"

  count = var.enabled ? 1 : 0

  argocd_namespace          = var.argocd_namespace
  application_namespace     = var.challenge_namespace
  application_name          = var.application_name != null ? var.application_name : "${var.category}-${var.identifier}"
  application_repo_url      = var.application_repo_url
  application_repo_path     = var.path != null ? var.path : "challenges/${var.category}/${var.identifier}/k8s/challenge"
  application_repo_revision = var.revision
  application_project       = var.argocd_project
  helm                      = var.helm

  argocd_labels = {
    "part-of"   = "ctfpilot"
    "component" = "challenge"
    "version"   = var.revision
    "category"  = var.category
    "instance"  = var.identifier
  }
}

