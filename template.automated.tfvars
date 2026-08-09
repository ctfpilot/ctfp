# Template for the automated setup process.
# Clone this file to `automated.tfvars` and fill in the values.
# This file (`template.automated.tfvars`) is git tracked, and MUST NOT be changed in the repository to include sensitive information.

# ------------------------
# CLI Tool configuration
# ------------------------
# The following variables are used by the CLI tool to configure the backend connection.
# Specifically setting the credentials to access the Terraform S3 backend.
terraform_backend_s3_access_key = "<access_key>" # Access key for the S3 backend
terraform_backend_s3_secret_key = "<secret_key>" # Secret key for the S3 backend

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
# Cluster configuration
# ------------------------
# WARNING: Changing region while the cluster is running will cause all servers in the group to be destroyed and recreated.
# For optimal performance, it is recommended to use the same region for all servers. If you want redundancy, use different regions for each group.
# Region 1 is used for challs nodes, scale nodes and loadbalancer.
# Possible values: fsn1, hel1, nbg1, ash, hil, sin - See https://docs.hetzner.com/cloud/general/locations/
region_1     = "nbg1"       # Region for group 1, challs nodes, scale nodes and loadbalancer
region_2     = "nbg1"       # Region for group 2
region_3     = "nbg1"       # Region for group 3
network_zone = "eu-central" # Hetzner network zone. Possible values: "eu-central", "us-east", "us-west", "ap-southeast". Regions must be within the network zone.

# Servers
# Server definitions are split into four groups: Control Plane, Agents, Challs and Scale. Control plane and agents has three groups each, while challs and scale is one group each.
# Each group can be scaled and defined independently, to allow for smooth transitions between different server types and sizes.
# Control planes are the servers that run the Kubernetes control plane, and are responsible for managing the cluster. 
# Agents are the servers that run the workloads, and scale is used to scale the cluster up or down dynamically.
# Challs are the servers that run the CTF challenges.
# Scale is automatically scaled agent nodes, which is handled by the cluster autoscaler. It is optional, and can be used to scale the cluster up or down dynamically if there is not enough resources in the cluster.
# Challs and scale nodes are placed in region_1, and are tainted to make normal resources prefer agent nodes, but allow scheduling on challs and scale nodes if needed.

# Server types. See https://www.hetzner.com/cloud
# Control plane nodes - Nodes that run the Kubernetes control plane components.
control_plane_type_1 = "cx23" # Control plane group 1
control_plane_type_2 = "cx23" # Control plane group 2
control_plane_type_3 = "cx23" # Control plane group 3
# Agent nodes - Nodes that run general workloads, excluding CTF challenges.
agent_type_1 = "cx33" # Agent group 1
agent_type_2 = "cx33" # Agent group 2
agent_type_3 = "cx33" # Agent group 3
# Challenge nodes - Nodes dedicated to running CTF challenges.
challs_type = "cx33" # CTF challenge nodes
# Scale nodes - Nodes that are automatically scaled by the cluster autoscaler. These nodes are used to scale the cluster up or down dynamically.
scale_type = "cx33" # Scale group

# Server count 
# Control plane nodes - Nodes that run the Kubernetes control plane components.
# Minimum of 1 control plane across all groups. 1 in each group is recommended for HA.
# Maximum of 10 control plane nodes in total. More than 10 is not supported due to placement group limitations.
control_plane_count_1 = 1 # Number of control plane nodes in group 1.
control_plane_count_2 = 1 # Number of control plane nodes in group 2.
control_plane_count_3 = 1 # Number of control plane nodes in group 3.
# Agent nodes - Nodes that run general workloads, excluding CTF challenges.
# Minimum of 1 agent across all groups. 1 in each group is recommended for HA.
# Maximum of 10 agent nodes total. More than 10 is not supported due to placement group limitations.
agent_count_1 = 1 # Number of agent nodes in group 1.
agent_count_2 = 1 # Number of agent nodes in group 2.
agent_count_3 = 1 # Number of agent nodes in group 3.
# Challenge nodes - Nodes dedicated to running CTF challenges. These nodes are tainted to only run challenge workloads.
# Minimum of 1 challenge node is required. If no challenge nodes are deployed, challenges cannot be deployed. 
# Maximum of 10 challenge nodes is supported due to placement group limitations.
challs_count = 1 # Number of challenge nodes.
# Scale nodes - Nodes that are automatically scaled by the cluster autoscaler. These nodes are used to scale the cluster up or down dynamically.
# Scale nodes are not placed in a placement group, and can be scaled as much as Hetzner cloud allows.
scale_max = 0 # Maximum number of scale nodes. Set to 0 to disable autoscaling.

load_balancer_type = "lb11" # Load balancer type, see https://www.hetzner.com/cloud/load-balancer

# Traefik ingress configuration
traefik_additional_ports = [] # List of additional ports to open on the load balancer. Each port is defined by a name, an internal port, and an external port. The name is used as `entryPoints` in IngressRouteTCP resources. The external port is exposed on the load balancer, while the internal port is exposed by the Traefik pods.
traefik_trusted_ips      = [] # List of additional trusted IPs to pass to Traefik in CIDR notation. Load balancer IPs are automatically added to this list. Add other trusted IPs here as a list of strings.

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
# This is to separate the two parts of the cluster, and to allow for different DNS records for the two parts. It may be the same domain. The specific subdomains is set later.
cloudflare_api_token      = "<api-token>"         # Cloudflare API Token for updating the DNS records (Zone.Zone.Read and Zone.DNS.Edit permissions required for the two following domains)
cloudflare_dns_management = "<management-domain>" # The top level domain (TLD) to use for the DNS records for the management part of the cluster
cloudflare_dns_platform   = "<platform-domain>"   # The top level domain (TLD) to use for the DNS records for the platform part of the cluster
cloudflare_dns_ctf        = "<ctf-domain>"        # The top level domain (TLD) to use for the DNS records for the CTF part of the cluster

# ------------------------
# DNS information
# ------------------------
# The cluster uses two domains for the management and CTF parts of the cluster.
# The following is the actually used subdomains for the two parts of the cluster. They may be either TLD or subdomains.
cluster_dns_management = "<dns-management-domain>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_platform   = "<dns-platform-domain>"   # The domain name to use for the DNS records for the platform part of the cluster
cluster_dns_ctf        = "<dns-ctf-domain>"        # The domain name to use for the DNS records for the CTF part of the cluster

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
# user: The username for the basic auth 
# password: The password for the basic auth
traefik_basic_auth = { user = "<basic-username>", password = "<basic-password>" }

traefik_redis_password = "<password>" # Password for the Traefik Redis backend
# traefik_redis_cluster_size = null   # Number of Redis cluster nodes for Traefik. Defaults to 3 for standard and HA, and 1 for single-node deployment types.

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
kubectf_container_secret = "<kubectf-container-secret>" # The secret to use for the containerSecret in the CTF configuration
# kubectf_host           = "<kubectf-host>"           # The host to use for the CTF configuration. It is recommended to not configure this, unless you use a remote kubeCTF instance. If not configured, it will default to "chall-manager.<cluster_dns_management>"

# ------------------------
# DB configuration
# ------------------------
db_root_password = "<db-root-password>" # Root password for the MariaDB cluster
# db_timezone      = "UTC"              # Timezone for the MariaDB cluster (e.g. "+2:00" or "UTC") and the backup cron schedule. DB timezone is immutable after cluster creation; backup schedule timezone can be changed anytime. Default is "UTC".
# db_anti_affinity = null               # Whether to enable anti-affinity for the MariaDB cluster pods. Defaults to true for standard and HA, and false for single-node deployment types. More information at https://github.com/mariadb-operator/mariadb-operator/blob/main/docs/high_availability.md#pod-anti-affinity.

# S3 backup
db_s3_bucket     = "<bucket>"     # S3 bucket name for backups
db_s3_region     = "<region>"     # S3 region for backups
db_s3_endpoint   = "<endpoint>"   # S3 endpoint for backups
db_s3_access_key = "<access_key>" # Access key for S3 for backups
db_s3_secret_key = "<secret_key>" # Secret key for S3 for backups

# Redis
# ctfd_redis_replicas = null       # Number of Redis replicas for CTFd. Defaults to 3 for standard and HA, and 1 for single-node deployment types.

# ------------------------
# CTFd Manager configuration
# ------------------------
# The CTFd manager is used to manage the CTFd instance, and is not used for the CTFd instance itself.
ctfd_manager_password      = "<password>"   # Password for the CTFd Manager
ctfd_manager_github_repo   = "<repository>" # Github repository used in the CTFd Manager. Env variable GITHUB_REPO. See https://github.com/ctfpilot/ctfd-manager
ctfd_manager_github_branch = ""             # Github branch used in the CTFd Manager. Leave empty for environment based branch (environment == prod ? main : develop). Env variable GITHUB_BRANCH. See https://github.com/ctfpilot/ctfd-manager

# ------------------------
# CTFd configuration
# ------------------------
# One or more CTFs can be defined here. Each CTF is defined as a map with the following keys:
ctfs = [
  {
    slug                    = "<slug>"        # Slug for the CTF event. This will be used in internal namings and must be unique. It should be a lowercase string with no spaces or special characters.
    subdomain               = "<subdomain>"   # A subdomain to the `cluster_dns_platform`, or empty string if you want to use the `cluster_dns_platform` directly. This will be used to generate the CTF URL.
    name                    = "<name>"        # Name of the CTF. This is the name of the CTF event that will be displayed on the platform.
    description             = "<description>" # Description of the CTF event.
    start_time              = "<start_time>"  # Start time of the CTF event in ISO 8601 format (e.g., '2023-10-01T00:00:00Z')
    end_time                = "<end_time>"    # End time of the CTF event in ISO 8601 format (e.g., '2023-10-02T00:00:00Z')
    registration_code       = "<code>"        # Registration code for the CTF.
    user_mode               = "<mode>"        # User mode for CTFd (e.g., 'teams'). Possible valeus: "teams", "users".
    challenge_visibility    = "<visibility>"  # Challenge visibility (e.g., 'public'). Possible valeus: "public", "private" or "admins".
    account_visibility      = "<visibility>"  # Account visibility (e.g., 'private'). Possible valeus: "public", "private" or "admins".
    score_visibility        = "<visibility>"  # Score visibility (e.g., 'public'). Possible valeus: "public", "private", "hidden" or "admins".
    registration_visibility = "<visibility>"  # Registration visibility (e.g., 'public'). Possible valeus: "public", "private" or "Mmlc".
    verify_emails           = true            # Whether to verify emails
    team_size               = 0               # Team size for the CTF. 0 means no limit
    brackets = [                              # List of brackets for the CTF (optional).
      {
        name        = "<bracket_name>"        # Name of the bracket.
        description = "<bracket_description>" # Description of the bracket.
        type        = "<bracket_type>"        # Type of bracket. Possible values: "" (empty), "users", "teams".
      }
    ]
    theme         = "<theme>"       # Theme for CTFd
    ctf_logo_path = "data/logo.png" # Full path to the CTF logo file from the platform directory (e.g., '/data/logo.png')

    admin = {                 # Admin user configuration for the CTF. This user will be created during the CTF setup.
      name     = "<name>"     # Name of the admin user.
      email    = "<email>"    # Email of the admin user.
      password = "<password>" # Password for the admin user.
    }

    mail = {                       # Mail configuration for the CTF. This is used to send emails from the CTF platform.
      host     = "<mail_host>"     # Mail server host. Defaults to `ctf_mail_host` if not provided.
      port     = "<mail_port>"     # Mail server port. Defaults to `ctf_mail_port` if not provided.
      tls      = "<mail_tls>"      # Whether to use TLS for the mail server. Defaults to `ctf_mail_tls` if not provided.
      username = "<mail_username>" # Username for the mail server. Defaults to `ctf_mail_username` if not provided.
      password = "<mail_password>" # Password for the mail server. Defaults to `ctf_mail_password` if not provided.
      from     = "<mail_from>"     # From address for the mail server. Defaults to `ctf_mail_from` if not provided.
    }

    plugins = {                                             # Plugins configuration for the CTF. This is used to configure the plugins for the CTF platform.
      kubectf_auth_secret = "<plugins_kubectf_auth_secret>" # Secret for the kubectf_auth plugin. Defaults to `kubectf_auth_secret` if not provided.
      # kubectf_host        = "<plugins_kubectf_host>"        # Host for the kubectf plugin. Defaults to `kubectf_host` if not provided.
      first_blood_url     = "<plugins_first_blood_url>"     # URL for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_url` if not provided.
      first_blood_message = "<plugins_first_blood_message>" # Message for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_message` if not provided.
      first_blood_limit   = "<plugins_first_blood_limit>"   # Limit for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_limit` if not provided.
    }

    ctfd = {                                                         # CTFd configuration for the CTF. This is used to configure the CTFd instance.
      secret_key                = "<ctfd_secret_key>"                # Secret key for CTFd
      s3_prefix                 = "<ctfd_s3_prefix>"                 # S3 storage prefix. Defaults to `slug` if not provided
      k8s_deployment_repository = "<ctfd_k8s_deployment_repository>" # Repository URL for CTFd deployment files. Example: https://github.com/ctfpilot/ctfd. Defaults to `ctfd_k8s_deployment_repository` if not provided
      k8s_deployment_path       = "<ctfd_k8s_deployment_path>"       # Path for CTFd deployment files within the git repository (i.e `k8s`). Defaults to `ctfd_k8s_deployment_path` if not provided
      k8s_deployment_branch     = "<ctfd_k8s_deployment_branch>"     # Git branch for CTFd deployment files. Defaults to `ctfd_k8s_deployment_branch` if not provided
    }

    db = {                       # Database configuration for the CTF. This is used to configure the MariaDB database for the CTFd instance.
      user     = "<db_user>"     # Database user
      password = "<db_password>" # Database user password
    }

    redis = {                       # Redis configuration for the CTF. This is used to configure the Redis instance for the CTFd instance.
      password = "<redis_password>" # Password for the Redis instance, for the CTFd instance.
    }

    pages = {                           # CTFd Pages configuration for the CTF. This is used to configure the pages deployed to the CTF.
      pages      = []                   # List of pages to deploy to CTFd. Needs to be the slugs available in the `pages` directory in the `pages_repository` and `pages_branch`.
      repository = "<pages_repository>" # Repository URL for pages. Defaults to `pages_repository` if not provided.
      branch     = "<pages_branch>"     # Git branch for pages. Defaults to `pages_branch` if not provided.
    }
  }
]

# Fallback mail configuration
ctf_mail_server   = "<server>"   # Mail server for CTFd
ctf_mail_port     = 465          # Mail server port
ctf_mail_username = "<username>" # Mail server username
ctf_mail_password = "<password>" # Mail server password
ctf_mail_tls      = true         # Whether to use TLS for the mail server
ctf_mail_from     = "<from>"     # From address for the mail server

# CTFd S3 Configuration
ctf_s3_bucket     = "<bucket>"     # S3 bucket name for CTFd files
ctf_s3_region     = "<region>"     # S3 region for CTFd files
ctf_s3_endpoint   = "<endpoint>"   # S3 endpoint for CTFd files
ctf_s3_access_key = "<access_key>" # Access key for S3 for CTFd files
ctf_s3_secret_key = "<secret_key>" # Secret key for S3 for CTFd files

# Fallback CTFd Plugin Configuration
ctfd_plugin_first_blood_url     = "<url>"                                                                               # Webhook URL for the First Blood plugin
ctfd_plugin_first_blood_limit   = "1"                                                                                   # Limit configuration for the First Blood plugin
ctfd_plugin_first_blood_message = ":drop_of_blood: First blood for **{challenge}** goes to **{user}**! :drop_of_blood:" # Message configuration for the First Blood plugin

# Fallback pages Configuration
pages_repository = "<repository>" # Repository URL for pages
pages_branch     = ""             # Git branch for pages. Leave empty for environment based branch (environment == prod ? main : develop)

# Fallback CTFd Deployment Configuration
ctfd_k8s_deployment_repository = "https://github.com/ctfpilot/ctfd" # Repository URL for CTFd deployment files
ctfd_k8s_deployment_path       = "k8s"                              # Path for CTFd deployment files within the git repository
ctfd_k8s_deployment_branch     = ""                                 # Git branch for CTFd deployment files. Leave empty for environment based branch (environment == prod ? main : develop)

# ------------------------
# Challenges configuration
# ------------------------
chall_whitelist_ips = ["<ip1>", "<ip2>"] # List of IPs to whitelist for challenge access

challenges_static = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of static challenges to deploy. Needs to be the slugs of the challenges
challenges_shared = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of shared challenges to deploy. Needs to be the slugs of the challenges
challenges_instanced = {
  "<category>" = ["<challenge_slug1>", "<challenge_slug2>"],
} # List of instanced challenges to deploy. Needs to be the slugs of the challenges

challenges_repository = "https://github.com/<repo>" # URL of the Git repository containing the challenge definitions
challenges_branch     = ""                          # Branch of the Git repository to use for the challenge definitions. Leave empty for environment based branch (environment == prod ? main : develop)

# ----------------------
# Docker images
# ----------------------
# Values are maintained within each component as defaults.
# You can override these values by uncommenting and setting your own images here.

# image_error_fallback      = "ghcr.io/ctfpilot/error-fallback:1.2.1"      # The docker image for the error fallback deployment. See https://github.com/ctfpilot/error-fallback
# image_filebeat            = "docker.elastic.co/beats/filebeat:8.19.19"    # The docker image for Filebeat
# image_ctfd_manager        = "ghcr.io/ctfpilot/ctfd-manager:1.0.1"        # Docker image for the CTFd Manager deployment
# image_ctfd_exporter       = "ghcr.io/the0mikkel/ctfd-exporter:1.1.1"     # Docker image for the CTFd Exporter
# image_instancing_fallback = "ghcr.io/ctfpilot/instancing-fallback:1.0.2" # The docker image for the instancing fallback deployment. See https://github.com/ctfpilot/instancing-fallback
# image_kubectf             = "ghcr.io/ctfpilot/kube-ctf:1.0.1"            # The docker image for the kube-ctf deployment. See https://github.com/ctfpilot/kube-ctf

# ----------------------
# Versions
# ----------------------
# Values are maintained within each component as defaults.
# You can override these values by uncommenting and setting your own versions here.

# kube_hetzner_version          = "2.21.0" # The version of the Kube-Hetzner module to use. More information at https://github.com/mysticaltech/terraform-hcloud-kube-hetzner
# argocd_version                = "10.2.1"  # The version of the ArgoCD Helm chart to deploy. More information at https://github.com/argoproj/argo-helm
# cert_manager_version          = "1.20.0" # The version of the Cert-Manager Helm chart to deploy. More information at https://github.com/cert-manager/cert-manager
# descheduler_version           = "0.36.0" # The version of descheduler Helm chart to deploy. More information at https://github.com/kubernetes-sigs/descheduler
# mariadb_operator_version      = "26.6.0" # The version of the MariaDB Operator Helm chart to deploy. More information at https://github.com/mariadb-operator/mariadb-operator
# kube_prometheus_stack_version = "87.21.0" # The version of the kube-prometheus-stack Helm chart to deploy. More information at https://github.com/prometheus-community/helm-charts/
# redis_operator_version        = "0.25.0" # The version of the Redis Operator Helm chart to deploy. More information at https://github.com/OT-CONTAINER-KIT/redis-operator
# mariadb_version               = "26.6.0" # The version of MariaDB deploy. More information at https://github.com/mariadb-operator/mariadb-operator

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
# argocd_application_set_replicas = null # Number of replicas for the ArgoCD ApplicationSet controller deployment. If not specified, it will be set to 1 or 2 (ha) based on the deployment type.
# errors_replicas = null # Number of replicas for the error fallback deployment. If not specified, it will be set to 1 (single-node), 2 (standard), or 3 (ha) based on the deployment type.
# default_web_replicas = null # Number of replicas for the default web deployment. If not specified, it will be set to 1 (single-node), 2 (standard), or 3 (ha) based on the deployment type.
# prometheus_replicas = null # Number of replicas for the Prometheus deployment. If not specified, it will be set to 1 (single-node or standard) or 2 (ha) based on the deployment type.
# traefik_min_replicas = null # Minimum number of Traefik replicas. If not specified, it will be set to 1 (single-node) or 3 (standard/ha) based on the deployment type.
# traefik_max_replicas = null # Maximum number of Traefik replicas. If not specified, it will be set to 10 (single-node) or 25 (standard/ha) based on the deployment type.
