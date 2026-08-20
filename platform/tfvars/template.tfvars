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
kubeconfig = "AA==" # Base64 encoded kubeconfig file

# ------------------------
# Generic information
# ------------------------
environment            = "test"  # Environment name for the CTF
cluster_dns_management = "<dns>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_platform   = "<dns>" # The domain name to use for the DNS records for the platform part of the cluster

# ------------------------
# GitHub variables
# ------------------------
ghcr_username = "<username>" # GitHub Container Registry username
ghcr_token    = "<token>"    # GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access
git_token     = "<token>"    # GitHub repo token. Only let this token have read access to the needed repositories.

# ----------------------
# Management configuration
# ----------------------
traefik_redis_password = "<password>" # Password for the Traefik Redis backend
# traefik_redis_cluster_size = null   # Number of Redis cluster nodes for Traefik. Defaults to 3 for standard and HA, and 1 for single-node deployment types.

# ----------------------
# Filebeat configuration
# ----------------------
filebeat_elasticsearch_host     = "<host>"     # The hostname of the Elasticsearch instance for Filebeat to send logs to. Must be a https 443 endpoint.
filebeat_elasticsearch_username = "<username>" # The username for Elasticsearch authentication.
filebeat_elasticsearch_password = "<password>" # The password for Elasticsearch authentication.

# ----------------------
# CTF configuration
# ----------------------
# The following is the configuration for the instanced challenge management system.
# They should be unique and strong passwords.
kubectf_auth_secret = "<kubectf-auth-secret>" # The secret to use for the authSecret in the CTF configuration
# kubectf_host      = "<kubectf-host>"        # The host to use for the CTF configuration. It is recommended to not configure this, unless you use a remote kubeCTF instance. If not configured, it will default to "chall-manager.<cluster_dns_management>"

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

    challenges = {
      config = {
        # default_points     = 1000 # Challenge default points, provided to CTFd manager. Optional, defaults to `challenges_default_points` if not provided.
        # default_min_points = 1000 # Challenge default minimum points, provided to CTFd manager. Only applicable for dynamic scored challenges. Optional, defaults to `challenges_default_min_points` if not provided.
        # default_decay      = 75 # Challenge default decay, provided to CTFd manager. Only applicable for dynamic scored challenges. Optional, defaults to `challenges_default_decay` if not provided.
      }
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
challenges_default_points     = 1000 # Challenge default points, provided to CTFd manager. Optional
challenges_default_min_points = 100  # Challenge default minimum points, provided to CTFd manager. Only applicable for dynamic scored challenges. Optional
challenges_default_decay      = 50   # Challenge default decay, provided to CTFd manager. Only applicable for dynamic scored challenges. Optional

# ----------------------
# Docker images
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own images here.

# image_ctfd_manager   = "ghcr.io/ctfpilot/ctfd-manager:1.0.1"     # Docker image for the CTFd Manager deployment
# image_error_fallback = "ghcr.io/ctfpilot/error-fallback:1.2.1"   # Docker image for the error fallback deployment
# image_filebeat       = "docker.elastic.co/beats/filebeat:8.19.19" # Docker image for Filebeat
# image_ctfd_exporter  = "ghcr.io/the0mikkel/ctfd-exporter:1.1.1"  # Docker image for the CTFd Exporter

# ----------------------
# Versions
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own versions here.

# mariadb_version = "26.6.0" # The version of MariaDB deploy. More information at https://github.com/mariadb-operator/mariadb-operator
