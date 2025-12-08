# ------------------------
# Variables
# ------------------------

variable "kubeconfig" {
  type        = string
  description = "Base64 encoded kubeconfig file"
  sensitive   = true
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment name for the CTF"
  default     = "test"
  nullable    = false
}

variable "cluster_dns_management" {
  type        = string
  description = "The specific domain name to use for the DNS records for the management part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_management`"
  nullable    = false
}

variable "cluster_dns_platform" {
  type        = string
  description = "The domain name to use for the DNS records for the platform part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_platform`"
  nullable    = false
}

variable "ghcr_username" {
  description = "GitHub Container Registry username"
  type        = string
  nullable    = false
}

variable "ghcr_token" {
  description = "GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "git_token" {
  description = "GitHub repo token. Only let this token have read access to the needed repositories."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "fluentd_elasticsearch_host" {
  type        = string
  nullable    = false
  description = "The hostname of the Elasticsearch instance for Fluentd to send logs to. Must be a https 443 endpoint."
}

variable "fluentd_elasticsearch_username" {
  type        = string
  nullable    = false
  description = "The username for Elasticsearch authentication."
}

variable "fluentd_elasticsearch_password" {
  type        = string
  nullable    = false
  description = "The password for Elasticsearch authentication."
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "kubectf_auth_secret" {
  type        = string
  nullable    = false
  description = "The secret to use for the authSecret in the CTF configuration"
  sensitive   = true
}

variable "db_root_password" {
  type        = string
  description = "Root password for the MariaDB cluster"
  sensitive   = true
  nullable    = false
}

variable "db_user" {
  type        = string
  description = "Database user"
  default     = "ctfd"
  nullable    = false
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
  default     = "password"
  nullable    = false
}

variable "ctfd_secret_key" {
  type        = string
  description = "Secret key for CTFd"
  sensitive   = true
  nullable    = false
}

variable "ctfd_manager_password" {
  type        = string
  description = "Password for the CTFd manager"
  sensitive   = true
  default     = "password"
  nullable    = false
}

variable "s3_bucket" {
  description = "S3 bucket name for backups"
  type        = string
  nullable    = false
}

variable "s3_region" {
  description = "S3 region for backups"
  type        = string
  nullable    = false
}

variable "s3_endpoint" {
  description = "S3 endpoint for backups"
  type        = string
  nullable    = false
}

variable "s3_access_key" {
  description = "Access key for S3 for backups"
  type        = string
  nullable    = false
}

variable "s3_secret_key" {
  description = "Secret key for S3 for backups"
  type        = string
  nullable    = false
}

variable "ctf_s3_bucket" {
  description = "S3 bucket name for CTFd files"
  type        = string
  nullable    = false
}

variable "ctf_s3_region" {
  description = "S3 region for CTFd files"
  type        = string
  nullable    = false
}

variable "ctf_s3_endpoint" {
  description = "S3 endpoint for CTFd files"
  type        = string
}

variable "ctf_s3_access_key" {
  description = "Access key for S3 for CTFd files"
  type        = string
  nullable    = false
}

variable "ctf_s3_secret_key" {
  description = "Secret key for S3 for CTFd files"
  type        = string
  nullable    = false
}

variable "ctf_s3_prefix" {
  description = "S3 prefix for CTFd files, e.g., 'ctfd/dev/'"
  type        = string
  default     = "ctfd/"
  nullable    = false
}

variable "ctfd_k8s_deployment_repository" {
  type        = string
  description = "Repository URL for CTFd deployment files. Example: https://github.com/ctfpilot/ctfd"
  default     = "https://github.com/ctfpilot/ctfd"
}

variable "ctfd_k8s_deployment_path" {
  type        = string
  description = "Path for CTFd deployment files within the git repository (i.e `k8s`)"
  default     = "k8s"
}

variable "ctfd_k8s_deployment_branch" {
  type        = string
  description = "Git branch for CTFd deployment files. Leave empty for environment based branch (environment == prod ? main : develop)"
  default     = ""
}

variable "ctfd_plugin_first_blood_limit_url" {
  description = "CTFd Plugin configuration: First blood (ctfd-discord-webhook-plugin). Webhook url configuration (url)."
  type        = string
  nullable    = false
}

variable "ctfd_plugin_first_blood_limit" {
  type        = string
  description = "CTFd Plugin configuration: First blood (ctfd-discord-webhook-plugin). Limit configuration (limit)."
  default     = "1"
}

variable "ctfd_plugin_first_blood_message" {
  type        = string
  description = "CTFd Plugin configuration: First blood (ctfd-discord-webhook-plugin). Message configuration (message)."
  default     = ":drop_of_blood: First blood for **{challenge}** goes to **{user}**! :drop_of_blood:"
}

variable "ctfd_manager_github_repo" {
  type        = string
  description = "Github repository used in the CTFd Manager. Env variable GITHUB_REPO. See https://github.com/ctfpilot/ctfd-manager"
  nullable    = false
}

variable "ctfd_manager_github_branch" {
  type        = string
  description = "Github branch used in the CTFd Manager. Leave empty for environment based branch (environment == prod ? main : develop). Env variable GITHUB_BRANCH. See https://github.com/ctfpilot/ctfd-manager"
  default     = ""
}

variable "pages" {
  type        = list(string)
  description = "List of pages to deploy to CTFd. Needs to be the slugs available in the `pages` directory in the `pages_repository`"
  default     = []
}

variable "pages_repository" {
  type        = string
  description = "Repository URL for pages, generated using the challenge-toolkit. See https://github.com/ctfpilot/challenge-toolkit"
  nullable    = false
}

variable "pages_branch" {
  type        = string
  description = "Git branch for pages. Leave empty for environment based branch (environment == prod ? main : develop)"
  default     = ""
}

variable "image_ctfd_manager" {
  type        = string
  description = "The docker image for the ctfd-manager deployment. See https://github.com/ctfpilot/ctfd-manager"
  default     = "ghcr.io/ctfpilot/ctfd-manager:1.0.1"
}

variable "image_error_fallback" {
  type        = string
  description = "The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback"
  default     = "ghcr.io/ctfpilot/error-fallback:1.2.1"
}

variable "image_filebeat" {
  type        = string
  description = "The docker image for Filebeat"
  default     = "docker.elastic.co/beats/filebeat:8.19.0"
}

variable "image_ctfd_exporter" {
  type        = string
  description = "The docker image for CTFd Exporter"
  default     = "ghcr.io/the0mikkel/ctfd-exporter:1.1.1"
}
