resource "kubernetes_manifest" "ip_whitelist_web" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "challenge-ipwhitelist-web"
      namespace = "ctfpilot-challenges"
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
    }
    spec = {
      ipAllowList = {
        sourceRange = var.chall_whitelist_ips
      }
    }
  }
}
