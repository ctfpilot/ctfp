terraform {
  required_version = ">= 1.9.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }
  }
}

variable "org_name" {
  description = "Name of the organization. Used for labeling resources"
  type        = string
}

variable "max_instances" {
  description = "Maximum number of instances to run per team"
  type        = number
  default     = 4
}

variable "challenge_dns" {
  description = "DNS name for the challenges, may be the same as the challenges as subdomains will be used (challanges.<challenge_dns>)"
  type        = string
}

variable "management_dns" {
  description = "DNS name for the management interface, may be the same as the challenges as subdomains will be used (management.<management_dns>)"
  type        = string
}

variable "cert_manager" {
  description = "Cert manager to use for issuing certificates"
  type        = string
}

variable "management_auth_secret" {
  description = "Auth secret used for the management interface"
  type        = string
}

variable "container_secret" {
  description = "Secret used for the containers"
  type        = string
}

variable "image_landing" {
  description = "Image to use for the landing page"
  type        = string
  default     = "themikkel/ctf:landing"
}

variable "image_challenge_manager" {
  description = "Image to use for the challenge manager"
  type        = string
  default     = "themikkel/ctf:manager"
}

variable "registry_prefix" {
  description = "Prefix for the container registry"
  type        = string
  default     = "docker.io"
}

variable "ghcr_username" {
  description = "GitHub Container Registry username"
  type        = string
  default     = ""
}

variable "ghcr_token" {
  description = "GitHub Container Registry token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "services_replicas" {
  description = "Number of replicas to run for the services"
  type        = number
  default     = 1
}
