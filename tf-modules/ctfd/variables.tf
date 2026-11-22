# -----------------------
# Variables
# -----------------------

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

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# -----------------------
# CTF variables
# -----------------------

variable "ctf_slug" {
  description = "Slug for the CTF event. This will be used in internal namings and must be unique. It should be a lowercase string with no spaces or special characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.ctf_slug))
    error_message = "ctf_slug must be a lowercase string with no spaces or special characters. Only letters, numbers, and hyphens are allowed."
  }

  validation {
    condition     = length(var.ctf_slug) >= 2
    error_message = "ctf_slug must be at least 2 characters long."
  }
}

variable "ctf_url" {
  description = "URL of the CTFd instance. This should be the public URL where CTFd will be accessible, without scheme or path (e.g., 'ctfd.example.com')."
  type        = string
}

variable "ctf_name" {
  description = "Name of the CTF. This is the name of the CTF event that will be displayed on the platform."
  type        = string
}

variable "ctf_description" {
  description = "Description of the CTF event."
  type        = string
}

variable "ctf_start_time" {
  description = "Start time of the CTF event in ISO 8601 format (e.g., '2023-10-01T00:00:00Z')"
  type        = string
  default     = ""
}

variable "ctf_end_time" {
  description = "End time of the CTF event in ISO 8601 format (e.g., '2023-10-31T23:59:59Z')"
  type        = string
  default     = ""
}

variable "ctf_user_mode" {
  description = "User mode for CTFd (e.g., 'teams'). Possible valeus: 'teams', 'users'."
  type        = string
  validation {
    condition     = contains(["teams", "users"], var.ctf_user_mode)
    error_message = "ctf_user_mode must be either 'teams' or 'users'."
  }
}

variable "ctf_challenge_visibility" {
  description = "Challenge visibility (e.g., 'public'). Possible valeus: 'public', 'private' or 'admins."
  type        = string
  validation {
    condition     = contains(["public", "private", "admins"], var.ctf_challenge_visibility)
    error_message = "ctf_challenge_visibility must be either 'public', 'private', or 'admins'."
  }
}

variable "ctf_account_visibility" {
  description = "Account visibility (e.g., 'private'). Possible valeus: 'public', 'private' or 'admins'."
  type        = string
  validation {
    condition     = contains(["public", "private", "admins"], var.ctf_account_visibility)
    error_message = "ctf_account_visibility must be either 'public', 'private', or 'admins'."
  }
}

variable "ctf_score_visibility" {
  description = "Score visibility (e.g., 'public'). Possible valeus: 'public', 'private', 'hidden' or 'admins'."
  type        = string
  validation {
    condition     = contains(["public", "private", "hidden", "admins"], var.ctf_score_visibility)
    error_message = "ctf_score_visibility must be either 'public', 'private', 'hidden', or 'admins'."
  }
}

variable "ctf_registration_visibility" {
  description = "Registration visibility (e.g., 'public'). Possible valeus: 'public', 'private' or 'Mmlc'."
  type        = string
  validation {
    condition     = contains(["public", "private", "Mmlc"], var.ctf_registration_visibility)
    error_message = "ctf_registration_visibility must be either 'public', 'private', or 'Mmlc'."
  }
}

variable "ctf_verify_emails" {
  description = "Whether to verify emails."
  type        = bool
  default     = true
}

variable "ctf_team_size" {
  description = "Team size for the CTF. 0 means no limit."
  type        = number
  default     = 0
}

variable "ctf_brackets" {
  description = "List of brackets for the CTF (optional)."
  type = list(object({
    name        = string
    description = optional(string)
    type        = optional(string) # empty, "users" or "teams"
  }))
  default = []
  validation {
    condition     = alltrue([for b in var.ctf_brackets : contains(["", "users", "teams"], b.type)])
    error_message = "Each bracket type must be either '', 'users', or 'teams'."
  }
}

variable "ctf_theme" {
  description = "Theme for CTFd."
  type        = string
  default     = "core-kubectf"
}

variable "ctf_admin_name" {
  description = "Name of the admin user."
  type        = string
}

variable "ctf_admin_email" {
  description = "Email of the admin user."
  type        = string
}

variable "ctf_admin_password" {
  description = "Password for the admin user."
  type        = string
  sensitive   = true
}

variable "ctf_registration_code" {
  description = "Registration code for the CTF."
  type        = string
}

variable "ctf_mail_server" {
  description = "Mail server for CTFd"
  type        = string
}

variable "ctf_mail_port" {
  description = "Mail server port"
  type        = number
  default     = 465
}

variable "ctf_mail_username" {
  description = "Mail server username"
  type        = string
}

variable "ctf_mail_password" {
  description = "Mail server password"
  type        = string
  sensitive   = true
}

variable "ctf_mail_tls" {
  description = "Whether to use TLS for the mail server"
  type        = bool
  default     = true
}

variable "ctf_mail_from" {
  description = "From address for the mail server"
  type        = string
}

variable "ctf_logo_path" {
  description = "Path to the CTF logo file from the platform directory (e.g., 'data/logo.png')"
  type        = string
  default     = "data/logo.png"
}

# -----------------------
# CTF Plugins configuration
# -----------------------

variable "kubectf_auth_secret" {
  type        = string
  nullable    = false
  description = "The secret to use for the authSecret in the CTF configuration"
  sensitive   = true
}

variable "kubectf_host" {
  type        = string
  nullable    = false
  description = "The host to use for the CTF configuration"
}

variable "ctfd_plugin_first_blood_url" {
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

# -----------------------
# CTFd deployment
# -----------------------

variable "ctfd_secret_key" {
  type        = string
  description = "Secret key for CTFd"
  sensitive   = true
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
  description = "Git branch for CTFd deployment files."
  default     = ""

  validation {
    condition     = length(var.ctfd_k8s_deployment_branch) <= 255
    error_message = "ctfd_k8s_deployment_branch must be 255 characters or less."
  }

  validation {
    condition     = length(var.ctfd_k8s_deployment_branch) > 0
    error_message = "ctfd_k8s_deployment_branch cannot be empty. Please specify a valid branch name."
  }
}

variable "image_ctfd_exporter" {
  type        = string
  description = "The docker image for CTFd Exporter"
  default     = "ghcr.io/the0mikkel/ctfd-exporter:1.1.1"
}

# -----------------------
# CTFd manager
# -----------------------

variable "ctf_manager_namespace" {
  description = "Namespace for the CTFd manager"
  type        = string
  default     = "challenge-config"
}

variable "ctf_manager_url" {
  description = "URL of the CTFd manager instance. This should be the public URL where the CTFd manager will be accessible, without scheme or path (e.g., 'manager.example.com')."
  type        = string
}

variable "ctfd_manager_password" {
  type        = string
  description = "Password for the CTFd manager"
  sensitive   = true
  default     = "password"
  nullable    = false
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

variable "image_ctfd_manager" {
  type        = string
  description = "The docker image for the ctfd-manager deployment. See https://github.com/ctfpilot/ctfd-manager"
  default     = "ghcr.io/ctfpilot/ctfd-manager:1.0.1"
}

variable "challenges_default_points" {
  type        = number
  description = "Challenge default points, provided to CTFd manager."
  nullable    = false
}

variable "challenges_default_min_points" {
  type        = number
  description = "Challenge default minimum points, provided to CTFd manager. Only applicable for dynamic scored challenges."
  nullable    = false
}

variable "challenges_default_decay" {
  type        = number
  description = "Challenge default decay, provided to CTFd manager. Only applicable for dynamic scored challenges."
  nullable    = false
}

# -------------------------
# Pages
# -------------------------

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

# -------------------------
# Filebeat
# -------------------------

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

# -------------------------
# Database
# -------------------------

variable "db_cluster_name" {
  type        = string
  description = "Name of the MariaDB cluster for CTFd."
  nullable    = false
}

variable "db_cluster_namespace" {
  type        = string
  description = "Namespace for the MariaDB cluster for CTFd."
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

# -------------------------
# Redis
# -------------------------

variable "ctfd_redis_password" {
  type        = string
  description = "Password for the CTFd Redis instance"
  sensitive   = true
  nullable    = false
}

variable "ctfd_redis_replicas" {
  type        = number
  description = "Number of Redis replicas for CTFd. Defaults to 3 for standard and HA, and 1 for single-node deployment types."
  nullable    = true
  default     = null
}
