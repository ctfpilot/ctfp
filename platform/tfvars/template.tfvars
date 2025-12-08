# ------------------------
# Kubernetes variables
# ------------------------
kubeconfig = "AA==" # Base64 encoded kubeconfig file

# ------------------------
# Generic information
# ------------------------
environment            = "test"  # Environment name for the CTF
cluster_dns_management = "<dns>" # The specific domain name to use for the DNS records for the management part of the cluster
cluster_dns_ctf        = "<dns>" # The domain name to use for the DNS records for the CTF part of the cluster

# ------------------------
# GitHub variables
# ------------------------
ghcr_username = "<username>" # GitHub Container Registry username
ghcr_token    = "<token>"    # GitHub Container Registry token. This token is used to pull images from the GitHub Container Registry. Only let this token have registry read access
git_token     = "<token>"    # GitHub repo token. Only let this token have read access to the needed repositories.

# ----------------------
# Filebeat configuration
# ----------------------
filebeat_elasticsearch_host     = "<host>"     # The hostname of the Elasticsearch instance for Filebeat to send logs to. Must be a https 443 endpoint.
filebeat_elasticsearch_username = "<username>" # The username for Elasticsearch authentication.
filebeat_elasticsearch_password = "<password>" # The password for Elasticsearch authentication.

# ----------------------
# CTF configuration
# ----------------------
kubectf_auth_secret = "<secret>" # The secret to use for the authSecret in the CTF configuration


# ------------------------
# DB configuration
# ------------------------
db_root_password = "<password>" # Root password for the MariaDB cluster
db_user          = "ctfd"       # Database user
db_password      = "password"   # Database password

# S3 backup
s3_bucket     = "<bucket>"     # S3 bucket name for backups
s3_region     = "<region>"     # S3 region for backups
s3_endpoint   = "<endpoint>"   # S3 endpoint for backups
s3_access_key = "<access_key>" # Access key for S3 for backups
s3_secret_key = "<secret_key>" # Secret key for S3 for backups

# ------------------------
# CTFd Manager configuration
# ------------------------
ctfd_manager_password = "<password>" # Password for the CTFd Manager

# ------------------------
# CTFd configuration
# ------------------------
ctf_name                    = "<name>"        # Name of the CTF event
ctf_description             = "<description>" # Description of the CTF event
ctf_user_mode               = "<mode>"        # User mode for CTFd (e.g., "teams")
ctf_challenge_visibility    = "<visibility>"  # Challenge visibility (e.g., "public")
ctf_account_visibility      = "<visibility>"  # Account visibility (e.g., "private")
ctf_score_visibility        = "<visibility>"  # Score visibility (e.g., "public")
ctf_registration_visibility = "<visibility>"  # Registration visibility (e.g., "public")
ctf_verify_emails           = true            # Whether to verify emails
ctf_team_size               = 0               # Team size for the CTF. 0 means no limit
ctf_brackets                = []              # List of brackets, optional
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

ctf_logo_path = "data/logo.png" # Path to the CTF logo file (e.g., "ctf-logo.png")

ctfd_secret_key = "<secret>" # Secret key for CTFd

# CTFd S3 Configuration
ctf_s3_bucket     = "<bucket>"     # S3 bucket name for CTFd files
ctf_s3_region     = "<region>"     # S3 region for CTFd files
ctf_s3_endpoint   = "<endpoint>"   # S3 endpoint for CTFd files
ctf_s3_access_key = "<access_key>" # Access key for S3 for CTFd files
ctf_s3_secret_key = "<secret_key>" # Secret key for S3 for CTFd files
ctf_s3_prefix     = "ctfd/"        # S3 prefix for CTFd files, e.g., 'ctfd/dev/'

# CTFd Plugin Configuration
ctfd_plugin_first_blood_limit_url = "<url>"                                                                               # Webhook URL for the First Blood plugin
ctfd_plugin_first_blood_limit     = "1"                                                                                   # Limit configuration for the First Blood plugin
ctfd_plugin_first_blood_message   = ":drop_of_blood: First blood for **{challenge}** goes to **{user}**! :drop_of_blood:" # Message configuration for the First Blood plugin

# Pages Configuration
pages            = []             # List of pages to deploy to CTFd
pages_repository = "<repository>" # Repository URL for pages
pages_branch     = ""             # Git branch for pages. Leave empty for environment based branch (environment == prod ? main : develop)

# CTFd Deployment Configuration
ctfd_k8s_deployment_repository = "https://github.com/ctfpilot/ctfd" # Repository URL for CTFd deployment files
ctfd_k8s_deployment_path       = "k8s"                              # Path for CTFd deployment files within the git repository
ctfd_k8s_deployment_branch     = ""                                 # Git branch for CTFd deployment files. Leave empty for environment based branch (environment == prod ? main : develop)

# ----------------------
# Docker images
# ----------------------
# Values are maintained in the variables.tf file.
# You can override these values by uncommenting and setting your own images here.

# image_ctfd_manager   = "ghcr.io/ctfpilot/ctfd-manager:1.0.1"     # Docker image for the CTFd Manager deployment
# image_error_fallback = "ghcr.io/ctfpilot/error-fallback:1.2.1"  # Docker image for the error fallback deployment
# image_filebeat       = "docker.elastic.co/beats/filebeat:8.19.0" # Docker image for Filebeat
# image_ctfd_exporter  = "ghcr.io/the0mikkel/ctfd-exporter:1.1.1"  # Docker image for the CTFd Exporter

