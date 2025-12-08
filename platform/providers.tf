# ----------------------
# Terraform Configuration
# ----------------------

terraform {
  required_version = ">= 1.9.5"

  backend "s3" {}

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }

    htpasswd = {
      source = "loafoe/htpasswd"
    }

    http = {
      source = "hashicorp/http"
    }

    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
  }
}

# ----------------------
# Providers
# ----------------------

# Configure the REST API provider for CTFd Manager
provider "restapi" {
  uri = "https://themikkel.dk"

  headers = {
    "Authorization" = "Bearer ${var.ctfd_manager_password}"
    "Content-Type"  = "application/json"
  }

  write_returns_object = true

  create_method  = "GET"
  update_method  = null
  destroy_method = null
}

locals {
  kube_config = yamldecode(base64decode(var.kubeconfig))
}

provider "kubernetes" {
  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)

  client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
  client_key         = base64decode(local.kube_config.users[0].user.client-key-data)
}

provider "kubectl" {
  load_config_file = false

  host                   = local.kube_config.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)

  client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
  client_key         = base64decode(local.kube_config.users[0].user.client-key-data)
}

locals {
  env_branch = var.environment == "prod" ? "main" : "develop"
}