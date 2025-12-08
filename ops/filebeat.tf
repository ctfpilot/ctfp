resource "kubernetes_namespace" "logging-namespace" {
  metadata {
    name = "logging"
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "es_credentials" {
  metadata {
    name      = "es-credentials"
    namespace = kubernetes_namespace.logging-namespace.metadata.0.name
  }
  data = {
    "username" = var.filebeat_elasticsearch_username
    "password" = var.filebeat_elasticsearch_password
  }
  type = "Opaque"
}

resource "kubernetes_service_account" "filebeat_service_account" {
  metadata {
    name      = "filebeat"
    namespace = kubernetes_namespace.logging-namespace.metadata.0.name
  }
}

resource "kubernetes_cluster_role_v1" "filebeat_cluster_role" {
  metadata {
    name = "filebeat"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "serviceaccounts", "nodes", "endpoints"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "filebeat_cluster_role_binding" {
  metadata {
    name = "filebeat"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.filebeat_cluster_role.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.filebeat_service_account.metadata.0.name
    namespace = kubernetes_namespace.logging-namespace.metadata.0.name
  }
}

resource "kubernetes_config_map" "filebeat_config" {
  metadata {
    name      = "filebeat-config"
    namespace = kubernetes_namespace.logging-namespace.metadata.0.name
  }
  data = {
    "filebeat.yml" = <<-EOF
      filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*.log
        processors:
        - add_kubernetes_metadata:
            host: $${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
        - add_fields:
            target: ''
            fields:
              cluster_dns: "${var.cluster_dns_management}"

      output.elasticsearch:
        hosts: ["https://${var.filebeat_elasticsearch_host}:443"]
        username: "${var.filebeat_elasticsearch_username}"
        password: "${var.filebeat_elasticsearch_password}"
        protocol: https
        ssl.verification_mode: "full"
        index: filebeat-${var.environment}-logs

      setup:
        template:
          name: "filebeat-${var.environment}-logs"
          pattern: "filebeat-${var.environment}-logs*"
          overwrite: false
        ilm:
          enabled: true
          policy_name: "filebeat"
    EOF
  }
}

resource "kubernetes_daemonset" "filebeat_daemonset" {
  metadata {
    name      = "filebeat"
    namespace = kubernetes_namespace.logging-namespace.metadata.0.name
    labels = {
      k8s-app = "filebeat-logging"
      version = "v1"
      app     = "filebeat"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "filebeat-logging"
        version = "v1"
        app     = "filebeat"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "filebeat-logging"
          version = "v1"
          app     = "filebeat"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.filebeat_service_account.metadata.0.name

        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }
        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
        toleration {
          key    = "cluster.ctfpilot.com/node"
          value  = "scaler"
          effect = "PreferNoSchedule"
        }

        container {
          name  = "filebeat"
          image = var.image_filebeat
          security_context {
            privileged = true
          }
          env {
            name  = "ELASTICSEARCH_HOST"
            value = "https://${var.filebeat_elasticsearch_host}:443"
          }
          env {
            name = "ELASTICSEARCH_USERNAME"
            value_from {
              secret_key_ref {
                name = "es-credentials"
                key  = "username"
              }
            }
          }
          env {
            name = "ELASTICSEARCH_PASSWORD"
            value_from {
              secret_key_ref {
                name = "es-credentials"
                key  = "password"
              }
            }
          }
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "filebeat-config"
            mount_path = "/usr/share/filebeat/filebeat.yml"
            sub_path   = "filebeat.yml"
          }
        }

        termination_grace_period_seconds = 30

        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "filebeat-config"
          config_map {
            name = kubernetes_config_map.filebeat_config.metadata.0.name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.logging-namespace,
    kubernetes_secret.es_credentials,
    kubernetes_config_map.filebeat_config
  ]
}
