resource "kubernetes_namespace_v1" "mariadb" {
  metadata {
    name = "mariadb-operator"
  }
}

resource "helm_release" "mariadb-operator-crds" {
  name             = "mariadb-operator-crds"
  repository       = "https://helm.mariadb.com/mariadb-operator"
  namespace        = kubernetes_namespace_v1.mariadb.metadata.0.name
  create_namespace = false

  chart   = "mariadb-operator-crds"
  version = var.mariadb_operator_version

  // timeot 10min
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
  repository       = "https://helm.mariadb.com/mariadb-operator"
  namespace        = kubernetes_namespace_v1.mariadb.metadata.0.name
  create_namespace = false

  chart   = "mariadb-operator"
  version = var.mariadb_operator_version

  # timeot 10min
  timeout = 600

  // Force use of longhorn storage class
  # set = [{
  #   name  = "mariadb-operator.storageClass"
  #   value = "longhorn"
  # }]

  depends_on = [
    helm_release.mariadb-operator-crds,
    kubernetes_namespace_v1.mariadb
  ]
}
