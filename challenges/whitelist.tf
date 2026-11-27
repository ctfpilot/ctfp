locals {
  traefik_labels = {
    "app.kubernetes.io/name"      = "traefik"
    "app.kubernetes.io/component" = "challenges"
    "app.kubernetes.io/part-of"   = "ctfpilot"
    "ctfpilot.com/component"      = "challenges"
  }
}

resource "kubernetes_manifest" "ip_whitelist_web" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "challenge-ipwhitelist-web"
      namespace = "ctfpilot-challenges"

      labels = local.traefik_labels
    }
    spec = {
      ipAllowList = {
        sourceRange = var.chall_whitelist_ips
      }
    }
  }
}

resource "kubernetes_manifest" "ip_whitelist_instanced_web" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "challenge-ipwhitelist-web"
      namespace = "ctfpilot-challenges-instanced"

      labels = local.traefik_labels
    }
    spec = {
      ipAllowList = {
        sourceRange = var.chall_whitelist_ips
      }
    }
  }
}

resource "kubernetes_manifest" "ip_whitelist_tcp" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "MiddlewareTCP"
    metadata = {
      name      = "challenge-ipwhitelist-tcp"
      namespace = "ctfpilot-challenges"

      labels = local.traefik_labels
    }
    spec = {
      ipAllowList = {
        sourceRange = var.chall_whitelist_ips
      }
    }
  }
}

resource "kubernetes_manifest" "ip_whitelist_instanced_tcp" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "MiddlewareTCP"
    metadata = {
      name      = "challenge-ipwhitelist-tcp"
      namespace = "ctfpilot-challenges-instanced"

      labels = local.traefik_labels
    }
    spec = {
      ipAllowList = {
        sourceRange = var.chall_whitelist_ips
      }
    }
  }
}
