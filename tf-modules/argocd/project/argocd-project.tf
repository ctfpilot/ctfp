variable "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  default     = "argocd"
}

variable "project_name" {
  description = "The name of the project"

  validation {
    error_message = "The project name must be lowercase"
    condition     = can(regex("^[a-z0-9-]*$", var.project_name))
  }
}

variable "project_destinations" {
  description = "The destinations for the project"
  type = list(object({
    namespace = string
    server    = string
  }))

  default = [{
    namespace = "*"
    server    = "*"
  }]
}

resource "kubernetes_manifest" "project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = var.project_name
      namespace = var.argocd_namespace
    }
    spec = {
      destinations = var.project_destinations
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }
}
