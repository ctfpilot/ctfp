variable "name" {
  description = "Unique name for the secret"
}

variable "argocd_namespace" {
  description = "The namespace where the secret will be created in, should be the same as the ArgoCD namespace"
}

variable "ghcr_username" {
  description = "The username for the GitHub repository"
}

variable "git_token" {
  description = "The token for the GitHub repository"
}

variable "git_repo" {
  description = "The git repository to give access to"
}

variable "argocd_project" {
  description = "The ArgoCD project to use"
  default     = "default"

  validation {
    error_message = "The project name must be lowercase"
    condition     = can(regex("^[a-z0-9-]*$", var.argocd_project))
  }
}