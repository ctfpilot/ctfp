# ------------------------
# Kubernetes variables
# ------------------------
kubeconfig = "AA==" # The base64 encoded kubeconfig file (base64 -w 0 <file>)

# ------------------------
# Generic information
# ------------------------
environment            = "test"    # Deployment environment name for the CTF (i.e. prod, staging, dev, test)
cluster_dns_management = "<dns>"   # The domain name to use for the DNS records for the management part of the cluster
cluster_dns_ctf        = "<dns>"   # The domain name to use for the DNS records for the CTF part of the cluster
email                  = "<email>" # Email to use for the ACME certificate
discord_webhook_url    = "<url>"   # Discord webhook URL for sending alerts and notifications

# ------------------------
# Cloudflare variables
# ------------------------
cloudflare_api_token      = "<token>" # Cloudflare API Token for updating the DNS records (Zne.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
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

# ----------------------
# Docker images
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own images here.

# image_error_fallback = "ghcr.io/ctfpilot/error-fallback:latest" # The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback
# image_filebeat = "docker.elastic.co/beats/filebeat:8.19.0"      # The docker image for Filebeat

# ----------------------
# Versions
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own versions here.

# argocd_version                = "8.2.5"  # The version of the ArgoCD Helm chart to deploy. More information at https://github.com/argoproj/argo-helm
# cert_manager_version          = "1.17.1" # The version of the Cert-Manager Helm chart to deploy. More information at https://github.com/cert-manager/cert-manager
# descheduler_version           = "1.34" # The version of descheduler Helm chart to deploy. More information at https://github.com/kubernetes-sigs/descheduler
# mariadb_operator_version      = "25.8.1" # The version of the MariaDB Operator Helm chart to deploy. More information at https://github.com/mariadb-operator/mariadb-operator
# kube_prometheus_stack_version = "62.3.1" # The version of the kube-prometheus-stack Helm chart to deploy. More information at https://github.com/prometheus-community/helm-charts/
# redis_operator_version        = "0.22.2" # The version of the Redus Operator Helm chart to deploy. More information at https://github.com/OT-CONTAINER-KIT/redis-operator
