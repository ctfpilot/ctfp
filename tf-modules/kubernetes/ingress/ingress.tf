variable "hostname" {
  description = "The hostname to route traffic to"
}

variable "namespace" {
  description = "The namespace to deploy the ingress to"
}

variable "service_name" {
  description = "The name of the service to route traffic to"
}

variable "ingress_name" {
  description = "The name of the ingress resource"
  default     = null
}

variable "service_port" {
  description = "The port of the service to route traffic to"
  default     = 80
}

variable "cluster_issuer_name" {
  description = "The name of the cluster issuer to use for the ingress"
  default     = "cert-manager-global"
}

variable "traefik_middleware" {
  description = "The name of the Traefik middleware to use"
  default     = "errors-errors@kubernetescrd"
}



resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = var.ingress_name != null ? var.ingress_name : var.service_name
    namespace = var.namespace

    annotations = {
      "cert-manager.io/cluster-issuer" = var.cluster_issuer_name
      "traefik.ingress.kubernetes.io/router.middlewares" = var.traefik_middleware
    }
  }

  spec {
    ingress_class_name = "traefik"
    default_backend {
      service {
        name = var.service_name
        port {
          number = 80
        }
      }
    }

    rule {
      host = var.hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = var.service_name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [
        "${var.hostname}"
      ]

      secret_name = "${var.hostname}-cert"
    }
  }
}
