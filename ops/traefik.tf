resource "kubernetes_service" "traefik_dashboard" {
  metadata {
    name      = "traefik-dashboard"
    namespace = var.traefik_namespace
    labels = {
      app     = "traefik"
      release = "traefik"
      role    = "dashboard"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "traefik"
    }

    port {
      name        = "dashboard"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "traefik-dashboard-ingress" {
  metadata {
    name      = "traefik-dashboard-ingress"
    namespace = var.traefik_namespace

    # Basic auth
    annotations = {
      "cert-manager.io/cluster-issuer"                   = module.cert_manager.cluster_issuer_name
      "ingress.kubernetes.io/auth-realm"                 = "traefik"
      "ingress.kubernetes.io/auth-type"                  = "basic"
      "ingress.kubernetes.io/auth-secret"                = kubernetes_secret.traefik_basic_auth.metadata.0.name
      "traefik.ingress.kubernetes.io/router.middlewares" = "${var.traefik_namespace}-${kubernetes_secret.traefik_basic_auth.metadata.0.name}@kubernetescrd,errors-errors@kubernetescrd"
    }
  }

  spec {
    default_backend {
      service {
        name = "traefik-dashboard"
        port {
          number = 8080
        }
      }
    }

    rule {
      host = "traefik.${var.cluster_dns_management}"
      http {
        path {
          backend {
            service {
              name = "traefik-dashboard"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [
        "traefik.${var.cluster_dns_management}"
      ]
      secret_name = "traefik-dashboard-tls-cert"
    }
  }

  depends_on = [
    kubernetes_secret.traefik_basic_auth,
    kubernetes_service.traefik_dashboard
  ]
}

resource "kubernetes_service" "traefik_metrics" {
  metadata {
    name      = "traefik-metrics"
    namespace = var.traefik_namespace
    labels = {
      app     = "traefik"
      role    = "metrics"
      release = "prometheus"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "traefik"
    }

    port {
      name        = "metrics"
      port        = 9100
      target_port = 9100
    }
  }
}



resource "kubernetes_config_map_v1" "ctfd_filebeat_config" {
  metadata {
    name      = "ctfd-filebeat-config"
    namespace = var.traefik_namespace
  }

  data = {
    "filebeat.yml" = <<-EOF
      filebeat.inputs:
      - type: filestream
        paths:
          - /var/log/traefik/*.log
        processors:
        - add_fields:
            target: ''
            fields:
              cluster_dns: "${var.cluster_dns_management}"
        - decode_json_fields:
            fields: ["message"]
            process_array: false
            max_depth: 1
            target: "traefik"
            overwrite_keys: false
        - drop_fields:
            fields: ["ecs.version"]

      output.elasticsearch:
        hosts: ["https://${var.filebeat_elasticsearch_host}:443"]
        username: "${var.filebeat_elasticsearch_username}"
        password: "${var.filebeat_elasticsearch_password}"
        protocol: https
        ssl.verification_mode: "full"
        index: filebeat-${var.environment}-access

      setup:
        template:
          name: "filebeat-${var.environment}-access"
          pattern: "filebeat-${var.environment}-access*"
          overwrite: false
        ilm:
          enabled: true
          policy_name: "filebeat"
    EOF
  }
}

resource "kubernetes_manifest" "traefik-additional-config" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"
    metadata = {
      name      = "traefik"
      namespace = "kube-system"
    }

    # This amends the Helm chart for the traefik ingress controller which is included with k3s.
    # https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml
    spec = {
      valuesContent = <<-EOF
        autoscaling:
          enabled: true
          minReplicas: 3
          maxReplicas: 50
        resources:
          requests:
            cpu: "500m"
            memory: "100Mi"
          limits:
            cpu: "2000m"
            memory: "1Gi"
        tolerations:
          - key: "cluster.ctfpilot.com/node"
            value: "scaler"
            effect: "PreferNoSchedule"
        logs:
          access:
            enabled: true
            format: json
            filePath: "/var/log/traefik/access.log"
            bufferingSize: 1000
            fields:
              headers:
                defaultmode: keep
                names:
                  Accept: drop
                  Connection: drop
                  Authorization: redact
        env:
        - name: TZ
          value: "Europe/Copenhagen"
        deployment:
          initContainers:
          - name: fix-permissions
            image: busybox:latest
            command: ["sh", "-c", "mkdir -p /usr/share/filebeat/data"]
            securityContext:
              fsGroup: 1000
            volumeMounts:
            - name: filebeat-data
              mountPath: /usr/share/filebeat/data
          additionalContainers:
          - image: ${var.image_filebeat}
            imagePullPolicy: Always
            name: traefik-stream-accesslog
            volumeMounts:
            - name: logs
              mountPath: /var/log/traefik
            - name: ctfd-filebeat-config
              mountPath: /usr/share/filebeat/filebeat.yml
              subPath: filebeat.yml
            - name: filebeat-data
              mountPath: /usr/share/filebeat/data
            resources:
              requests:
                cpu: "10m"
                memory: "56M"
              limits:
                cpu: "100m"
                memory: "256M"         
          additionalVolumes:
          - name: logs
          - name: ctfd-filebeat-config
            configMap:
              name: ctfd-filebeat-config
          - name: filebeat-data
            emptyDir: {}
        additionalVolumeMounts:
        - name: logs
          mountPath: /var/log/traefik
        hub:
          redis:
            cluster: true
            endpoints: redis-cluster-leaders:6379
      EOF
    }
  }

  depends_on = [
    kubernetes_config_map_v1.ctfd_filebeat_config
  ]
}
