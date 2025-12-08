variable "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "application_namespace" {
  description = "The namespace where the application will be deployed"
}

variable "application_name" {
  description = "The name of the application"
}

variable "application_repo_url" {
  description = "The URL of the repository where the application manifests are stored"
}

variable "application_repo_path" {
  description = "The path within the repository where the application manifests are stored"
}

variable "application_repo_revision" {
  description = "The revision of the repository to use"
}

variable "application_project" {
  description = "The ArgoCD project to use"
  default     = "default"

  validation {
    error_message = "The project name must be lowercase"
    condition     = can(regex("^[a-z0-9-]*$", var.application_project))
  }
}

variable "argocd_labels" {
  description = "The labels to apply to the ArgoCD Application"
  type        = map(string)
  default     = {}

}

variable "argocd_finalizers" {
  description = "The finalizers to apply to the ArgoCD Application"
  type        = list(string)
  default     = ["resources-finalizer.argocd.argoproj.io"]
}

variable "helm" {
  description = "Helm chart configuration"
  type        = any
  default     = null
}

locals {
  argocd_source = merge(
    {
      repoURL        = var.application_repo_url
      path           = var.application_repo_path
      targetRevision = var.application_repo_revision
    },
    var.helm != null ? { helm = var.helm } : {}
  )
}

resource "kubernetes_manifest" "application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.application_name
      namespace = var.argocd_namespace

      labels = merge(
        {
          "managed-by" = "terraform"
        },
        var.argocd_labels
      )
      finalizers = length(var.argocd_finalizers) > 0 ? var.argocd_finalizers : null
    }
    spec = {
      project = var.application_project
      source = local.argocd_source
      destination = {
        namespace = var.application_namespace
        server    = "https://kubernetes.default.svc"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
