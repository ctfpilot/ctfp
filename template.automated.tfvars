# Template for the automated setup process.
# Clone this file to `automated.tfvars` and fill in the values.
# This file (`template.automated.tfvars`) is git tracked, and MUST NOT be changed in the repository to include sensitive information.

# ------------------------
# IMPORTANT INFORMATION
# ------------------------
# FORMAT: key = "value"
# It is important keys and equal signs have AT LEAST one space between them.
# The values MUST be in quotes.
# Value MUST NOT be multiline.

# ------------------------
# Cluster configuration
# ------------------------
# WARNING: Changing region while the cluster is running will cause all servers in the group to be destroyed and recreated.
# For uptimal performance, it is recommended to use the same region for all servers.
# Region 1 is used for scale nodes and loadbalancer.
# Possible values: fsn1, hel1, nbg1
region_1 = "fsn1" # Region for subgroup 1
region_2 = "fsn1" # Region for subgroup 2
region_3 = "fsn1" # Region for subgroup 3

# Servers
# Server definitions are split into three groups: Control Plane, Agents, and Scale. Control plane and agents has three groups each, and scale has one group.
# Each group can be scaled and defined independently, to allow for smooth transitions between different server types and sizes.
# Control planes are the servers that run the Kubernetes control plane, and are responsible for managing the cluster. 
# Agents are the servers that run the workloads, and scale is used to scale the cluster up or down dynamically.
# Scale is automatically scaled agent nodes, which is handled by the cluster autoscaler. It is optional, and can be used to scale the cluster up or down dynamically.

# Server types (e.g., "cx32", "cx42", "cx22") See https://www.hetzner.com/cloud
control_plane_type_1 = "cx32" # Control plane group 1
control_plane_type_2 = "cx32" # Control plane group 2
control_plane_type_3 = "cx32" # Control plane group 3
agent_type_1         = "cx32" # Agent group 1
agent_type_2         = "cx32" # Agent group 2
agent_type_3         = "cx32" # Agent group 3
scale_type           = "cx32" # Scale group

# Server count 
# Minimum of 1 control plane across all groups. 1 in each group is recommended for HA.
control_plane_count_1 = 1 # Number of control plane nodes in group 1
control_plane_count_2 = 1 # Number of control plane nodes in group 2
control_plane_count_3 = 1 # Number of control plane nodes in group 3
# Minimum of 1 agent across all groups. 1 in each group is recommended for HA.
agent_count_1 = 1 # Number of agent nodes in group 1
agent_count_2 = 1 # Number of agent nodes in group 2
agent_count_3 = 1 # Number of agent nodes in group 3
# Optional - 0 means no scale nodes available to the autoscaler.
scale_count = 0
# Minimum number of scale nodes - Only applicable if scale_count > 0
scale_min = 0

load_balancer_type = "lb11" # Load balancer type, see https://www.hetzner.com/cloud/load-balancer

# ------------------------
# Hetzner
# ------------------------
hcloud_token = "<hetzner-token>" # Hetzner cloud project token (obtained from a specific project in Hetzner cloud)

# ------------------------
# SSH
# ------------------------
# The following tokens are base64 encoded public and private keys.
# To generate these, leave the template as is, and run the following commands to fill in the values:
# $ python3 cli.py generate-keys --insert
ssh_key_private_base64 = "<private_key>" # The private key to use for SSH access to the servers (base64 encoded)
ssh_key_public_base64  = "<public_key>"  # The public key to use for SSH access to the servers (base64 encoded)


# ------------------------
# Cloudflare variables
# ------------------------
# The cluster uses two domains for the management and CTF parts of the cluster.
# This is to sepearte the two parts of the cluster, and to allow for different DNS records for the two parts. It may be the same domain. The specific subdomains is set later.
cloudflare_api_token      = "<api-token>"         # Cloudflare API Token for updating the DNS records (Zne.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
cloudflare_dns_management = "<management-domain>" # The top level domain (TLD) to use for the DNS records for the management part of the cluster
cloudflare_dns_ctf        = "<ctf-domain>"        # The top level domain (TLD) to use for the DNS records for the CTF part of the cluster
cloudflare_dns_platform   = "<platform-domain>"   # The top level domain (TLD) to use for the DNS records for the platform part of the cluster

# ------------------------
# DNS information
# ------------------------
# The cluster uses two domains for the management and CTF parts of the cluster.
# The following is the actually used subdomains for the two parts of the cluster. They may be either TLD or subdomains.
cluster_dns_management = "<dns-management-domain>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_ctf        = "<dns-ctf-domain>"        # The domain name to use for the DNS records for the CTF part of the cluster
cluster_dns_platform   = "<dns-platform-domain>"   # The domain name to use for the DNS records for the platform part of the cluster

# The following is used for the ACME certificate (https) for the cluster.
email = "<email>" # Email to use for the ACME certificate


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
# The following MUST BE ONE LINE
# user: The username for the basic auth 
# password: The password for the basic auth
traefik_basic_auth = { user = "<basic-username>", password = "<basic-password>" }

# ----------------------
# Filebeat configuration
# ----------------------
filebeat_elasticsearch_host     = "<host>"     # The hostname of the Elasticsearch instance for Filebeat to send logs to. Must be a https 443 endpoint.
filebeat_elasticsearch_username = "<username>" # The username for the Elasticsearch instance
filebeat_elasticsearch_password = "<password>" # The password for the Elasticsearch instance


# ----------------------
# Github configuration
# ----------------------
# The following configures the cluster access to Github and needed Github repositories.
ghcr_username = "<gh-username>"   # GitHub Container Registry username
ghcr_token    = "<gh-repo-token>" # GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access
git_token     = "<gh-git-token>"  # GitHub repo token. Only let this token have read access to the needed repositories.

# ----------------------
# CTF configuration
# ----------------------
# The following is the configuration for the instanced challenge management system.
# They should be unique and strong passwords.
kubectf_auth_secret      = "<kubectf-auth-secret>"      # The secret to use for the authSecret in the CTF configuration
kubectf_container_secret = "<kubectl-container-secret>" # The secret to use for the containerSecret in the CTF configuration

# ------------------------
# DB configuration
# ------------------------
# DB configuration for the MariaDB cluster, used for the CTFd instance.
db_root_password = "<db-root-password>" # Root password for the MariaDB cluster
db_user          = "<db-user>"          # Database user
db_password      = "<db-password>"      # Database password

# ------------------------
# S3 configuration (for backups)
# ------------------------
s3_bucket     = "<s3-bucket>"     # S3 bucket name for backups
s3_region     = "<s3-region>"     # S3 region for backups
s3_endpoint   = "<s3-endpoint>"   # S3 endpoint for backups
s3_access_key = "<s3-access-key>" # Access key for S3 for backups
s3_secret_key = "<s3-secret-key>" # Secret key for S3 for backups

# ------------------------
# CTFd Manager configuration
# ------------------------
# The following is the configuration for the CTFd manager.
ctfd_manager_password = "<password>" # Password for the CTFd Manager
# The CTFd manager is used to manage the CTFd instance, and is not used for the CTFd instance itself.
ctfd_secret_key = "<ctfd-secret-key>" # Secret key for CTFd, used for the CTFd instance itself. This is used to sign cookies and other sensitive data. It should be a long, random string.

# ------------------------
# CTFd configuration
# ------------------------
ctf_name                    = "<name>"        # Name of the CTF event
ctf_description             = "<description>" # Description of the CTF event
ctf_start_time              = "<start-time>"  # Start time of the CTF event (ISO 8601 format, e.g., "2023-10-01T00:00:00Z")
ctf_end_time                = "<end-time>"    # End time of the CTF event
ctf_user_mode               = "<mode>"        # User mode for CTFd (e.g., "teams")
ctf_challenge_visibility    = "<visibility>"  # Challenge visibility (e.g., "public")
ctf_account_visibility      = "<visibility>"  # Account visibility (e.g., "private")
ctf_score_visibility        = "<visibility>"  # Score visibility (e.g., "public")
ctf_registration_visibility = "<visibility>"  # Registration visibility (e.g., "public")
ctf_verify_emails           = true            # Whether to verify emails
ctf_team_size               = 0               # Team size for the CTF. 0 means no limit
ctf_brackets                = []              # List of brackets, optional - Must be formatted as one line.
ctf_theme                   = "<theme>"       # Theme for CTFd
ctf_admin_name              = "<name>"        # Name of the admin user
ctf_admin_email             = "<email>"       # Email of the admin user
ctf_admin_password          = "<password>"    # Password for the admin user
ctf_registration_code       = "<code>"        # Registration code for the CTF

ctf_mail_server   = "<server>"   # Mail server for CTFd
ctf_mail_port     = 465          # Mail server port
ctf_mail_username = "<username>" # Mail server username
ctf_mail_password = "<password>" # Mail server password
ctf_mail_tls      = true         # Whether to use TLS for the mail server
ctf_mail_from     = "<from>"     # From address for the mail server

ctf_s3_bucket     = "<s3-bucket>"     # S3 bucket name for CTFd files
ctf_s3_region     = "<s3-region>"     # S3 region for CTF
ctf_s3_endpoint   = "<s3-endpoint>"   # S3 endpoint for CTFd files
ctf_s3_access_key = "<s3-access-key>" # Access key for S3 for CTFd files
ctf_s3_secret_key = "<s3-secret-key>" # Secret key for S3 for CTFd files
ctf_s3_prefix     = "ctfd/<prefix>/"  # S3 prefix for CTFd files, e.g., "ctfd/dev/"

ctf_logo_path = "data/logo.png" # Path to the CTF logo file (e.g., "ctf-logo.png")

ctfd_plugin_first_blood_limit_url = "<webhook-url>" # Discord webhook URL for First blood notifications

chall_whitelist_ips = ["<ip1>", "<ip2>"] # List of IPs to whitelist for challenges, e.g., [ "0.0.0.0/0" ]

# ----------------------
# Docker images
# ----------------------
# Values are maintained within each component as defaults.
# You can override these values by uncommenting and setting your own images here.

# image_error_fallback = "ghcr.io/ctfpilot/error-fallback:1.2.1" # The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback
# image_filebeat = "docker.elastic.co/beats/filebeat:8.19.0"      # The docker image for Filebeat

# ----------------------
# Versions
# ----------------------
# Values are maintained within each component as defaults.
# You can override these values by uncommenting and setting your own versions here.

# mariadb_operator_version = "25.8.1" # The version of the MariaDB Operator to deploy. More information at https://github.com/mariadb-operator/mariadb-operator
