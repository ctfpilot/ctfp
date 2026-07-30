resource "kubernetes_namespace_v1" "mariadb" {
  metadata {
    name = "mariadb-operator"
  }
}

locals {
  mariadb_operator_ha = var.deployment_type == "ha" ? [
    {
      name  = "ha.enabled"
      value = "true"
    },
    {
      name  = "ha.replicas"
      value = "3"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].key"
      value = "app.kubernetes.io/name"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].operator"
      value = "In"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[0].values[0]"
      value = "mariadb-operator"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[1].key"
      value = "app.kubernetes.io/instance"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[1].operator"
      value = "In"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchExpressions[1].values[0]"
      value = "mariadb-operator"
    },
    {
      name  = "affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey"
      value = "kubernetes.io/hostname"
    },
    {
      name  = "pdb.enabled"
      value = "true"
    },
    {
      name  = "pdb.maxUnavailable"
      value = "1"
    }
  ] : []
}

resource "helm_release" "mariadb-operator-crds" {
  name             = "mariadb-operator-crds"
  repository       = "https://mariadb-operator.github.io/mariadb-operator"
  namespace        = kubernetes_namespace_v1.mariadb.metadata.0.name
  create_namespace = false

  chart   = "mariadb-operator-crds"
  version = var.mariadb_operator_version

  // timeout 10min
  timeout = 600

  // Force use of longhorn storage class
  # set = [{
  #   name  = "mariadb-operator.storageClass"
  #   value = "longhorn"
  # }]

  depends_on = [
    kubernetes_namespace_v1.mariadb
  ]
}

resource "helm_release" "mariadb-operator" {
  name             = "mariadb-operator"
  repository       = "https://mariadb-operator.github.io/mariadb-operator"
  namespace        = kubernetes_namespace_v1.mariadb.metadata.0.name
  create_namespace = false

  chart   = "mariadb-operator"
  version = var.mariadb_operator_version

  # timeout 10min
  timeout = 600

  // Force use of longhorn storage class
  set = concat([
    # {
    #   name  = "mariadb-operator.storageClass"
    #   value = "longhorn"
    # },
  ], local.mariadb_operator_ha)

  depends_on = [
    helm_release.mariadb-operator-crds,
    kubernetes_namespace_v1.mariadb
  ]
}
