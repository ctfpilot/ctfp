resource "kubernetes_network_policy" "block-internal-traffic" {
  for_each = local.challenge_namespaces

  metadata {
    name      = "block-internal-traffic"
    namespace = each.value

    labels = {
      system = "kube-ctf"
      org    = var.org_name
    }
  }

  spec {
    pod_selector {
    }

    policy_types = [
    #   "Ingress",
      "Egress",
    ]

    # ingress {
    #   from {
    #     namespace_selector {
    #       match_labels = {
    #         name = "traefik"
    #       }
    #     }

    #     pod_selector {
    #       match_labels = {
    #         "app.kubernetes.io/name" = "traefik"
    #       }
    #     }
    #   }
    # }

    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
          except = [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.88.99.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "224.0.0.0/4",
            "240.0.0.0/4"
          ]
        }
      }
    }
  }

  depends_on = [
    local.challenge_namespaces
  ]
}


# resource "kubernetes_network_policy" "allow-interaction-logs" {
#   for_each = local.challenge_namespaces

#   metadata {
#     name      = "allow-interaction-logs"
#     namespace = each.value

#     labels = {
#       system = "kube-ctf"
#       org    = var.org_name
#     }
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         "kube-ctf.${var.org_name}/interaction-logs" = "true"
#       }
#     }

#     policy_types = ["Egress"]

#     egress {
#       ports {
#         protocol = "UDP"
#         port     = 53
#       }
#       ports {
#         protocol = "TCP"
#         port     = 53
#       }

#       to {
#         ip_block {
#           cidr = "127.0.0.0/8"
#         }
#       }
#       to {
#         ip_block {
#           cidr = "169.254.0.0/16"
#         }
#       }
#     }
#   }

#   depends_on = [
#     local.challenge_namespaces
#   ]
# }
