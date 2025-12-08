resource "kubernetes_namespace" "generic" {
  metadata {
    name = "kubectf"
    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "generic"
    }
  }
}

resource "kubernetes_namespace" "management" {
  metadata {
    name = "kubectf-management"
    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "admin"
    }
  }
}

output "namespace_management" {
  value = kubernetes_namespace.management.metadata.0.name
}

resource "kubernetes_namespace" "standard-challenges" {
  metadata {
    name = "ctfpilot-challenges"
    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "challenges"
    }
  }
}

output "namespace_standard_challenges" {
  value = kubernetes_namespace.standard-challenges.metadata.0.name
}

resource "kubernetes_namespace" "instanced-challenges" {
  metadata {
    name = "ctfpilot-challenges-instanced"
    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "challenges-instanced"
    }
  }
}

output "namespace_instanced_challenges" {
  value = kubernetes_namespace.instanced-challenges.metadata.0.name
}

locals {
  management_namespace = kubernetes_namespace.management.metadata.0.name

  challenge_namespaces = toset([
    kubernetes_namespace.instanced-challenges.metadata.0.name,
    kubernetes_namespace.standard-challenges.metadata.0.name,
  ])

  generic_namespace             = kubernetes_namespace.generic.metadata.0.name
  instanced_challenge_namespace = kubernetes_namespace.instanced-challenges.metadata.0.name
  standard_challenge_namespace  = kubernetes_namespace.standard-challenges.metadata.0.name
}

module "pull-secret" {
  source = "../pull-secret"

  for_each = var.ghcr_username != "" ? toset([
    local.management_namespace,
    local.generic_namespace,
    local.instanced_challenge_namespace,
    local.standard_challenge_namespace,
  ]) : toset([])

  namespace     = each.key
  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token

  depends_on = [
    kubernetes_namespace.management,
    kubernetes_namespace.instanced-challenges,
    kubernetes_namespace.standard-challenges,
  ]
}
