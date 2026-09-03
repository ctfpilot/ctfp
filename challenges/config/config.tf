variable "revision" {
  description = "The revision of the repository to use"
  default     = "main"
  nullable    = false
}

variable "category" {
  description = "The category of the challenge"
}

variable "identifier" {
  description = "The identifier of the challenge. The identifier may contain the revision in the format of `<identifier>:<revision>`. If the revision is not specified, the variable provided revision will be used."
}

variable "path" {
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

locals {
  revision = strcontains(var.identifier, ":") ? split(":", var.identifier)[1] : var.revision
  identifier = strcontains(var.identifier, ":") ? split(":", var.identifier)[0] : var.identifier
}

module "argocd-challenge-config" {
  source = "../../tf-modules/argocd/application"

  argocd_namespace          = var.argocd_namespace
  application_namespace     = var.config_namespace
  application_name          = var.application_name != null ? "${var.application_name}-config" : "${var.category}-${local.identifier}-config"
  application_repo_url      = var.application_repo_url
  application_repo_path     = var.path != null ? var.path : "challenges/${var.category}/${local.identifier}/k8s/config"
  application_repo_revision = local.revision
  application_project       = var.argocd_project
  helm                      = var.helm

  argocd_labels = {
    "part-of"   = "ctfpilot"
    "component" = "challenge-config"
    "version"   = replace(local.revision, "/", "-")
    "category"  = var.category
    "instance"  = local.identifier
  }
}
