# ----------------------
# Terraform Configuration
# ----------------------

terraform {
  required_version = ">= 1.6"

  backend "s3" {}

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.51.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52"
    }
  }
}

# ----------------------
# Providers
# ----------------------

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
