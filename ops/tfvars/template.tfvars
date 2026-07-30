# ------------------------
# Deployment type
# ------------------------
# Deployment type represents the type of deployment to be used for the platform.
# It defines how many replicas of each service is deployed. It does not affect node deployment.
# You may overwrite the number of replicas for each service at the bottom of this file, but it is not recommended to do so unless you know what you are doing.
#
# Options:
# - "standard": Standard deployment with core services being deployed with 2 or more replicas, while some services are deployed with 1 replica. This is the recommended deployment type for production (minimum 2 control plane nodes, 2 agent nodes, 1 challs node).
# - "single-node": Single node deployment with all services being deployed with 1 replica, and HA being disabled where possible, this is the recommended deployment type for small clusters (1 control plane node, 1 agent node, 1 challs node). This is not recommended for production.
# - "ha": High availability deployment with all services being deployed with 2 or more replicas, and HA enabled where possible. This is the recommended deployment type for large-scale events that require high availability and redundancy. Requires a minimum of 3 control plane nodes, 3 agent nodes and 1 challs node.
deployment_type = "standard" # Deployment type for the cluster. Options: "standard", "single-node", "ha"

# ------------------------
# Kubernetes variables
# ------------------------
kubeconfig = "AA==" # The base64 encoded kubeconfig file (base64 -w 0 <file>)

# ------------------------
# Generic information
# ------------------------
environment            = "test"    # Deployment environment name for the CTF (i.e. prod, staging, dev, test)
email                  = "<email>" # Email to use for the ACME certificate
discord_webhook_url    = "<url>"   # Discord webhook URL for sending alerts and notifications

# ------------------------
# Cloudflare variables
# ------------------------
cloudflare_api_token      = "<token>" # Cloudflare API Token for updating the DNS records (Zone.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
cloudflare_dns_management = "<dns>"   # The top level domain (TLD) to use for the DNS records for the management part of the cluster
cloudflare_dns_platform   = "<dns>"   # The top level domain (TLD) to use for the DNS records for the platform part of the cluster
cloudflare_dns_ctf        = "<dns>"   # The top level domain (TLD) to use for the DNS records for the CTF challenges part of the cluster
cluster_dns_management    = "<dns>"   # The specific domain name to use for the DNS records for the management part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_management`

# ----------------------
# Filebeat configuration
# ----------------------
filebeat_elasticsearch_host     = "<host>"     # The hostname of the Elasticsearch instance for Filebeat to send logs to. Must be a https 443 endpoint.
filebeat_elasticsearch_username = "<username>" # The username for the Elasticsearch instance
filebeat_elasticsearch_password = "<password>" # The password for the Elasticsearch instance

# ------------------------
# GitHub variables
# ------------------------
ghcr_username = "<username>" # GitHub Container Registry username
ghcr_token    = "<token>"    # GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access

# ----------------------
# Prometheus configuration
# ----------------------
prometheus_storage_size = "15Gi" # The size of the persistent volume claim for Prometheus data storage. Format: <size><unit> (e.g., 20Gi, 100Gi)

# ----------------------
# Management configuration
# ----------------------
# The following is the configuration for the management part of the cluster.

# ArgoCD password
argocd_admin_password = "<argocd-password>"      # The password for the ArgoCD admin user
argocd_github_secret  = "<argocd-github-secret>" # The GitHub secret for ArgoCD webhooks - Send webhook to /api/webhook with this secret as the secret header. This is used to trigger ArgoCD to sync the repositories.

# Grafana password
grafana_admin_password = "<grafana-password>" # The password for the Grafana admin user

# Alert endpoints
discord_webhook_url = "<discord-webhook-url>" # Discord webhook URL for notifications

# Username and password for basic auth (used for some management services)
# user: The username for the basic auth 
# password: The password for the basic auth
traefik_basic_auth = { user = "<basic-username>", password = "<basic-password>" }

traefik_redis_password = "<password>" # Password for the Traefik Redis backend

# ----------------------
# Docker images
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own images here.

# image_error_fallback = "ghcr.io/ctfpilot/error-fallback:1.2.1" # The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback
# image_filebeat = "docker.elastic.co/beats/filebeat:8.19.19"      # The docker image for Filebeat

# ----------------------
# Versions
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own versions here.

# argocd_version                = "10.2.1"  # The version of the ArgoCD Helm chart to deploy. More information at https://github.com/argoproj/argo-helm
# cert_manager_version          = "1.20.0" # The version of the Cert-Manager Helm chart to deploy. More information at https://github.com/cert-manager/cert-manager
# descheduler_version           = "0.36.0" # The version of descheduler Helm chart to deploy. More information at https://github.com/kubernetes-sigs/descheduler
# mariadb_operator_version      = "26.6.0" # The version of the MariaDB Operator Helm chart to deploy. More information at https://github.com/mariadb-operator/mariadb-operator
# kube_prometheus_stack_version = "87.21.0" # The version of the kube-prometheus-stack Helm chart to deploy. More information at https://github.com/prometheus-community/helm-charts/
# redis_operator_version        = "0.22.2" # The version of the Redis Operator Helm chart to deploy. More information at https://github.com/OT-CONTAINER-KIT/redis-operator

# ----------------------
# Replicas
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own replicas here.
# If set to null, behavior follows the deployment type. If set, it will override the deployment type.

# argocd_redis_ha = null # Whether to enable Redis HA for ArgoCD deployment. If not specified, it will be enabled if the deployment type is 'ha'.
# argocd_controller_replicas = null # Number of replicas for the ArgoCD controller deployment. If not specified, it will be set to 1.
# argocd_server_replicas = null # Number of replicas for the ArgoCD server deployment. If not specified, it will be set to 1 or 2 (ha)
# argocd_repo_server_replicas = null # Number of replicas for the ArgoCD repo server deployment. If not specified, it will be set to 1 or 2 (ha)
# argocd_application_set_replicas = null # Number of replicas for the ArgoCD ApplicationSet controller deployment. If not specified, it will be set to 1 or
# errors_replicas = null # Number of replicas for the error fallback deployment. If not specified, it will be set to 1 (single-node), 2 (standard), or 3 (ha) based on the deployment type.
# default_web_replicas = null # Number of replicas for the default web deployment. If not specified, it will be set to 1 (single-node), 2 (standard), or 3 (ha) based on the deployment type.
# prometheus_replicas = null # Number of replicas for the Prometheus deployment. If not specified, it will be set to 1 (single-node or standard) or 2 (ha) based on the deployment type.
# traefik_min_replicas = null # Minimum number of Traefik replicas. If not specified, it will be set to 1 (single-node) or 3 (standard/ha) based on the deployment type.
# traefik_max_replicas = null # Maximum number of Traefik replicas. If not specified, it will be set to 10 (single-node) or 25 (standard/ha) based on the deployment type.
