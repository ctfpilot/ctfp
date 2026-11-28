locals {
  labeled_charts = {
    argocd = {
      chart      = "argo-cd"
      repository = "https://argoproj.github.io/argo-helm"
      version    = var.argocd_version
    }
    mariadb-operator = {
      chart      = "mariadb-operator"
      repository = "https://mariadb-operator.github.io/mariadb-operator"
      version    = var.mariadb_operator_version
    }
    mariadb-operator-crds = {
      chart      = "mariadb-operator-crds"
      repository = "https://mariadb-operator.github.io/mariadb-operator"
      version    = var.mariadb_operator_version
    }
    prometheus = {
      chart      = "kube-prometheus-stack"
      repository = "https://prometheus-community.github.io/helm-charts"
      version    = var.kube_prometheus_stack_version
    }
    redis-operator = {
      chart      = "redis-operator"
      repository = "https://ot-container-kit.github.io/helm-charts/"
      version    = var.redis_operator_version
    }
  }
}

data "external" "labeled_chart" {
  for_each = local.labeled_charts

  program = ["python3", "${path.module}/charts/prepare.py"]
  query   = merge(each.value, { cache = "./.terraform/ctfp-charts" })
}

# Helm installs files in crds/ on fresh installs but skips existing CRDs.
resource "kubernetes_labels" "helm_crds" {
  for_each = merge({}, [for artifact in data.external.labeled_chart : jsondecode(artifact.result.crds)]...)

  api_version   = "apiextensions.k8s.io/v1"
  kind          = "CustomResourceDefinition"
  field_manager = "ctfpilot-helm-crds"
  force         = true

  metadata {
    name = each.key
  }
  labels = each.value

  depends_on = [
    helm_release.argocd,
    helm_release.mariadb-operator,
    helm_release.mariadb-operator-crds,
    helm_release.prometheus,
    helm_release.redis-operator,
  ]
}
