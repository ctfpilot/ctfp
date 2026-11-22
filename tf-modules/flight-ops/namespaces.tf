resource "kubernetes_namespace_v1" "generic" {
  metadata {
    name = "flight-ops"
    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "generic"
    }
  }
}

resource "kubernetes_namespace_v1" "groundcontrol" {
  metadata {
    name = "flight-ops-groundcontrol"
    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "admin"
    }
  }
}

output "namespace_groundcontrol" {
  value = kubernetes_namespace_v1.groundcontrol.metadata.0.name
}

resource "kubernetes_namespace_v1" "dispatcher" {
  metadata {
    name = "flight-ops-dispatcher"
    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "admin"
    }
  }
}

output "namespace_dispatcher" {
  value = kubernetes_namespace_v1.dispatcher.metadata.0.name
}

resource "kubernetes_namespace_v1" "standard-challenges" {
  metadata {
    name = "flights"
    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "challenges"
    }
  }
}

output "namespace_standard_challenges" {
  value = kubernetes_namespace_v1.standard-challenges.metadata.0.name
}

resource "kubernetes_namespace_v1" "instanced-challenges" {
  metadata {
    name = "flights-instanced"
    labels = {
      system = "flight-ops"
      org    = var.org_name

      "app.kubernetes.io/name"      = "flight-ops"
      "app.kubernetes.io/instance"  = "flight-ops"
      "app.kubernetes.io/component" = "challenges-instanced"
    }
  }
}

output "namespace_instanced_challenges" {
  value = kubernetes_namespace_v1.instanced-challenges.metadata.0.name
}

locals {
  dispatcher_namespace = kubernetes_namespace_v1.dispatcher.metadata.0.name
  groundcontrol_namespace = kubernetes_namespace_v1.groundcontrol.metadata.0.name

  challenge_namespaces = toset([
    kubernetes_namespace_v1.instanced-challenges.metadata.0.name,
    kubernetes_namespace_v1.standard-challenges.metadata.0.name,
  ])

  generic_namespace             = kubernetes_namespace_v1.generic.metadata.0.name
  instanced_challenge_namespace = kubernetes_namespace_v1.instanced-challenges.metadata.0.name
  standard_challenge_namespace  = kubernetes_namespace_v1.standard-challenges.metadata.0.name
}

module "pull-secret" {
  source = "../pull-secret"

  for_each = var.ghcr_username != "" ? toset([
    local.dispatcher_namespace,
    local.groundcontrol_namespace,
    local.generic_namespace,
    local.instanced_challenge_namespace,
    local.standard_challenge_namespace,
  ]) : toset([])

  namespace     = each.key
  ghcr_username = var.ghcr_username
  ghcr_token    = var.ghcr_token

  depends_on = [
    kubernetes_namespace_v1.groundcontrol,
    kubernetes_namespace_v1.dispatcher,
    kubernetes_namespace_v1.instanced-challenges,
    kubernetes_namespace_v1.standard-challenges,
  ]
}
