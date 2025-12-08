# ------------------------
# Variables
# ------------------------

variable "kubeconfig" {
  type        = string
  description = "Base64 encoded kubeconfig file"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Deployment environment name for the CTF (i.e. prod, staging, dev, test)"
  default     = "test"
}

variable "email" {
  description = "Email to use for the ACME certificate"
}

variable "cloudflare_api_token" {
  sensitive   = true # Requires terraform >= 0.14
  type        = string
  description = "Cloudflare API Token for updating the DNS records (Zne.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)"
}

variable "cloudflare_dns_management" {
  type        = string
  description = "The top level domain (TLD) to use for the DNS records for the management part of the cluster"
}

variable "cloudflare_dns_platform" {
  type        = string
  description = "The top level domain (TLD) to use for the DNS records for the platform part of the cluster"
}

variable "cloudflare_dns_ctf" {
  type        = string
  description = "The top level domain (TLD) to use for the DNS records for the CTF challenges part of the cluster"
}

variable "cluster_dns_management" {
  type        = string
  description = "The specific domain name to use for the DNS records for the management part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_management`"
}

variable "traefik_namespace" {
  type        = string
  default     = "traefik"
  description = "The Kubernetes namespace where Traefik is deployed"
}

variable "traefik_basic_auth" {
  type = map(string)
  default = {
    "user"     = "admin"
    "password" = "admin"
  }
  sensitive   = true
  description = "Username and password for basic auth. Format: { user = \"username\", password = \"password\" }"
}

variable "filebeat_elasticsearch_host" {
  type        = string
  nullable    = false
  description = "The hostname of the Elasticsearch instance for Filebeat to send logs to. Must be a https 443 endpoint."
}

variable "filebeat_elasticsearch_username" {
  type        = string
  nullable    = false
  description = "The username for Elasticsearch authentication."
}

variable "filebeat_elasticsearch_password" {
  type        = string
  nullable    = false
  description = "The password for Elasticsearch authentication."
}

variable "prometheus_storage_size" {
  type = "string"
  default = "15Gi"
  description = "The size of the persistent volume claim for Prometheus data storage. Format: <size><unit> (e.g., 20Gi, 100Gi)"
}

variable "discord_webhook_url" {
  type        = string
  description = "Discord webhook URL for notifications"
  sensitive   = true
}

variable "ghcr_username" {
  description = "GitHub Container Registry username"
  type        = string
}

variable "ghcr_token" {
  description = "GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access"
  type        = string
  sensitive   = true
}

variable "argocd_admin_password" {
  sensitive   = true
  type        = string
  description = "The password for the ArgoCD admin user"
}

variable "argocd_github_secret" {
  sensitive   = true
  type        = string
  description = "The GitHub secret for ArgoCD webhooks - Send webhook to /api/webhook with this secret as the secret header. This is used to trigger ArgoCD to sync the repositories."
}

variable "grafana_admin_password" {
  sensitive   = true
  type        = string
  description = "The password for the Grafana admin user"
}

variable "image_error_fallback" {
  type        = string
  description = "The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback"
  default     = "ghcr.io/ctfpilot/error-fallback:latest"
}

variable "image_filebeat" {
  type        = string
  description = "The docker image for Filebeat"
  default     = "docker.elastic.co/beats/filebeat:8.19.0"
}

# Variables
variable "argocd_version" {
  type        = string
  description = "The version of ArgoCD Helm chart to deploy. More information at https://github.com/argoproj/argo-helm"
  default     = "8.2.5"
}

variable "cert_manager_version" {
  type        = string
  description = "The version of cert-manager Helm chart to deploy. More information at https://github.com/cert-manager/cert-manager"
  default     = "1.17.1"
}

variable "descheduler_version" {
  type        = string
  description = "The version of descheduler Helm chart to deploy. More information at https://github.com/kubernetes-sigs/descheduler"
  default     = "1.34"
}

variable "mariadb_operator_version" {
  type        = string
  description = "The version of the MariaDB Operator Helm chart to deploy. More information at https://github.com/mariadb-operator/mariadb-operator"
  default     = "25.8.1"
}

variable "kube_prometheus_stack_version" {
  type        = string
  description = "The version of the kube-prometheus-stack Helm chart to deploy. More information at https://github.com/prometheus-community/helm-charts/"
  default = "62.3.1"
}

variable "redis_operator_version" {
  type = string
  description = "The version of the Redus Operator Helm chart to deploy. More information at https://github.com/OT-CONTAINER-KIT/redis-operator"
  default = "0.22.2"
}