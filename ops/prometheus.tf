resource "kubernetes_namespace_v1" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

# --- Grafana Dashboards ConfigMaps ---
resource "kubernetes_config_map" "grafana-dashboards-k8s" {
  metadata {
    name      = "grafana-dashboards-k8s"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/k8s"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/dashboards/k8s", "*.json") : file => file("${path.module}/prometheus/grafana/dashboards/k8s/${file}")
  }
}

resource "kubernetes_config_map" "grafana-dashboards-redis" {
  metadata {
    name      = "grafana-dashboards-redis"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/redis"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/dashboards/redis", "*.json") : file => file("${path.module}/prometheus/grafana/dashboards/redis/${file}")
  }
}

resource "kubernetes_config_map" "grafana-dashboards-traefik" {
  metadata {
    name      = "grafana-dashboards-traefik"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/traefik"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/dashboards/traefik", "*.json") : file => file("${path.module}/prometheus/grafana/dashboards/traefik/${file}")
  }
}

resource "kubernetes_config_map" "grafana-dashboards-ctf" {
  metadata {
    name      = "grafana-dashboards-ctf"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_dashboard = 1
    }

    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/ctf"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/dashboards/ctf", "*.json") : file => file("${path.module}/prometheus/grafana/dashboards/ctf/${file}")
  }
}

# --- Grafana Alerting Rules and Contacts ---
resource "kubernetes_secret" "grafana-alerts-contact-rules" {
  metadata {
    name      = "grafana-alerts-contact-rules"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_alert = "1"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/contact", "*.yaml") : file => templatefile("${path.module}/prometheus/grafana/contact/${file}", {
      cluster_dns_management = var.cluster_dns_management,
      discord_webhook_url    = var.discord_webhook_url,
    })
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "grafana-alerts-notification-rules" {
  metadata {
    name      = "grafana-alerts-notification-rules"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    labels = {
      grafana_alert = "1"
    }
  }

  data = {
    for file in fileset("${path.module}/prometheus/grafana/notification", "*.yaml") : file => templatefile("${path.module}/prometheus/grafana/notification/${file}", {
      cluster_dns_management = var.cluster_dns_management,
      discord_webhook_url    = var.discord_webhook_url,
    })
  }
}

# --- Prometheus Helm Release ---
resource "helm_release" "prometheus" {
  name = "prometheus"

  namespace        = kubernetes_namespace_v1.prometheus.metadata.0.name
  create_namespace = false

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version

  # Set password for grafana dashboard
  set_sensitive = [{
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }]

  # Use PVC for prometheus data
  set = [
    # {
    #   name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    #   value = "longhorn"
    # },
    {
      name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
      value = var.prometheus_storage_size
    }
  ]

  values = [
    templatefile("${path.module}/prometheus/kube_prometheus_custom_values.yaml", {
      cluster_dns_management = var.cluster_dns_management,
      discord_webhook_url    = var.discord_webhook_url,
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.prometheus,
    kubernetes_config_map.grafana-dashboards-k8s,
    kubernetes_config_map.grafana-dashboards-redis
  ]
}

# --- Grafana Ingress ---
resource "kubernetes_ingress_v1" "grafana-ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = kubernetes_namespace_v1.prometheus.metadata.0.name

    annotations = {
      "cert-manager.io/cluster-issuer"                   = module.cert_manager.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = "errors-errors@kubernetescrd"
    }
  }

  spec {
    default_backend {
      service {
        name = "prometheus-grafana"
        port {
          number = 80
        }
      }
    }

    rule {
      host = "grafana.${var.cluster_dns_management}"
      http {
        path {
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [
        "grafana.${var.cluster_dns_management}"
      ]
      secret_name = "grafana-ingress-tls-cert"
    }
  }

  depends_on = [
    helm_release.prometheus
  ]
}
