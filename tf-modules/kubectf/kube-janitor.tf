resource "kubernetes_config_map_v1" "kube-janitor" {
  metadata {
    name      = "kube-janitor"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf-kube-janitor-config"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "kube-janitor"
    }
  }

  data = {
    "rules.yaml" = <<EOF
rules:
- id: ctf-challenges-isolated-cleanup
  # clean up all isolated resources after this time, even if the user tries to extend it further
  resources:
  - deployments
  - ingressroutes
  - ingressroutetcps
  - services
  - ingresses
  jmespath: "metadata.namespace == '${local.instanced_challenge_namespace}' && metadata.name != 'landing'"
  ttl: 8h
        EOF
  }

  depends_on = [
    kubernetes_namespace.management,
    kubernetes_namespace.instanced-challenges,
  ]
}

resource "kubernetes_deployment_v1" "kube-janitor" {
  metadata {
    name      = "kube-janitor"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      application = "kube-janitor"
      version     = "v23.7.0"

      "app.kubernetes.io/name"      = "kube-ctf-kube-janitor"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "kube-janitor"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        application = "kube-janitor"
      }
    }

    template {
      metadata {
        labels = {
          application = "kube-janitor"
          version     = "v23.7.0"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.kube-janitor.metadata.0.name

        container {
          name = "kube-janitor"
          # see https://github.com/hjacobs/kube-janitor/releases
          image = "hjacobs/kube-janitor:23.7.0"

          args = [
            "--interval=120",
            "--rules-file=/config/rules.yaml",
            "--include-namespaces=${local.instanced_challenge_namespace}",
            "--include-resources=deployments,ingressroutes,ingressroutetcps,services,ingresses"
          ]

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "25m"
              memory = "64Mi"
            }
          }

          security_context {
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = 1000
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/config"
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = kubernetes_config_map_v1.kube-janitor.metadata.0.name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map_v1.kube-janitor
  ]
}

resource "kubernetes_service_account_v1" "kube-janitor" {
  metadata {
    name      = "kube-janitor"
    namespace = local.management_namespace

    labels = {
      system = "kube-ctf"
      org    = var.org_name

      "app.kubernetes.io/name"      = "kube-ctf-kube-janitor"
      "app.kubernetes.io/instance"  = "kubectf"
      "app.kubernetes.io/component" = "kube-janitor"
    }
  }

  depends_on = [
    kubernetes_namespace.management,
  ]
}

resource "kubernetes_cluster_role" "kube-janitor" {
  metadata {
    name = "kubectf-kube-janitor"
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "kube-janitor" {
  metadata {
    name      = "kube-janitor"
    namespace = local.instanced_challenge_namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kube-janitor.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.kube-janitor.metadata.0.name
    namespace = local.management_namespace
  }

  depends_on = [
    kubernetes_cluster_role.kube-janitor,
    kubernetes_service_account_v1.kube-janitor,
  ]
}
