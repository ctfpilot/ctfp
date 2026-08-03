variable "ctfs" {
  type = list(object({
    slug      = string # Slug for the CTF event. This will be used in internal namings and must be unique. It should be a lowercase string with no spaces or special characters.
    subdomain = string # A subdomain to the `cluster_dns_platform`, or empty string if you want to use the `cluster_dns_platform` directly. This will be used to generate the CTF URL.

    name              = string           # Name of the CTF. This is the name of the CTF event that will be displayed on the platform.
    description       = optional(string) # Description of the CTF event.
    start_time        = optional(string) # Start time of the CTF event in ISO 8601 format (e.g., '2023-10-01T00:00:00Z')
    end_time          = optional(string) # End time of the CTF event in ISO 8601 format (e.g., '2023-10-31T23:59:59Z')
    registration_code = optional(string) # Registration code for the CTF.

    user_mode               = string # User mode for CTFd (e.g., 'teams'). Possible valeus: "teams", "users".
    challenge_visibility    = string # Challenge visibility (e.g., 'public'). Possible valeus: "public", "private" or "admins".
    account_visibility      = string # Account visibility (e.g., 'private'). Possible valeus: "public", "private" or "admins".
    score_visibility        = string # Score visibility (e.g., 'public'). Possible valeus: "public", "private", "hidden" or "admins".
    registration_visibility = string # Registration visibility (e.g., 'public'). Possible valeus: "public", "private" or "Mmlc".
    verify_emails           = bool   # Whether to verify emails.
    team_size               = number # Team size for the CTF. 0 means no limit.
    brackets = list(object({         # List of brackets for the CTF (optional).
      name        = string           # Name of the bracket.
      description = optional(string) # Description of the bracket.
      type        = optional(string) # Type of bracket. Possible values: "" (empty), "users", "teams".
    }))

    theme     = string           # Theme for CTFd
    logo_path = optional(string) # Full path to the CTF logo file from the platform directory (e.g., '/data/logo.png')

    admin = object({    # Admin user configuration for the CTF. This user will be created during the CTF setup.
      name     = string # Name of the admin user.
      email    = string # Email of the admin user.
      password = string # Password for the admin user.
    })

    mail = object({               # Mail configuration for the CTF. This is used to send emails from the CTF platform.
      host     = optional(string) # Mail server host. Defaults to `ctf_mail_host` if not provided.
      port     = optional(number) # Mail server port. Defaults to `ctf_mail_port` if not provided.
      tls      = optional(bool)   # Whether to use TLS for the mail server. Defaults to `ctf_mail_tls` if not provided.
      username = optional(string) # Username for the mail server. Defaults to `ctf_mail_username` if not provided.
      password = optional(string) # Password for the mail server. Defaults to `ctf_mail_password` if not provided.
      from     = optional(string) # From address for the mail server. Defaults to `ctf_mail_from` if not provided.
    })

    plugins = object({                       # Plugins configuration for the CTF. This is used to configure the plugins for the CTF platform.
      kubectf_auth_secret = optional(string) # Secret for the kubectf_auth plugin. Defaults to `kubectf_auth_secret` if not provided.
      first_blood_url     = optional(string) # URL for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_url` if not provided.
      first_blood_message = optional(string) # Message for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_message` if not provided.
      first_blood_limit   = optional(number) # Limit for the first_blood plugin. Defaults to `ctfd_plugin_first_blood_limit` if not provided.
    })

    ctfd = object({                                # CTFd configuration for the CTF. This is used to configure the CTFd instance.
      secret_key                = string           # Secret key for CTFd
      s3_prefix                 = optional(string) # S3 storage prefix. Defaults to `slug` if not provided
      k8s_deployment_repository = optional(string) # Repository URL for CTFd deployment files. Example: https://github.com/ctfpilot/ctfd. Defaults to `ctfd_k8s_deployment_repository` if not provided
      k8s_deployment_path       = optional(string) # Path for CTFd deployment files within the git repository (i.e `k8s`). Defaults to `ctfd_k8s_deployment_path` if not provided
      k8s_deployment_branch     = optional(string) # Git branch for CTFd deployment files. Defaults to `ctfd_k8s_deployment_branch` if not provided
    })

    db = object({       # Database configuration for the CTF. This is used to configure the MariaDB database for the CTFd instance.
      user     = string # Database user
      password = string # Database user password
    })

    redis = object({    # Redis configuration for the CTF. This is used to configure the Redis instance for the CTFd instance.
      password = string # Password for the Redis instance, for the CTFd instance.
    })

    pages = object({                # CTFd Pages configuration for the CTF. This is used to configure the pages deployed to the CTF.
      pages      = list(string)     # List of pages to deploy to CTFd. Needs to be the slugs available in the `pages` directory in the `pages_repository` and `pages_branch`.
      repository = optional(string) # Repository URL for pages. Defaults to `pages_repository` if not provided.
      branch     = optional(string) # Git branch for pages. Defaults to `pages_branch` if not provided.
    })
  }))

  default = []

  sensitive = true

  validation {
    condition     = length(var.ctfs) > 0
    error_message = "The 'ctfs' variable must contain at least one CTF object."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.slug) > 0])
    error_message = "The 'slug' field in each CTF object must be a non-empty string."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : can(regex("^[a-zA-Z0-9._-]*$", ctf.slug))])
    error_message = "The 'slug' field in each CTF object must only contain alphanumeric characters, dots, underscores, or hyphens."
  }

  validation {
    condition     = length(distinct([for ctf in var.ctfs : ctf.slug])) == length(var.ctfs)
    error_message = "The 'slug' field in each CTF object must be unique."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : ctf.subdomain != null])
    error_message = "The 'subdomain' field in each CTF object must be non-null."
  }

  validation {
    condition     = length(distinct([for ctf in var.ctfs : ctf.subdomain])) == length(var.ctfs)
    error_message = "The 'subdomain' field in each CTF object must be unique."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.name) > 0])
    error_message = "The 'name' field in each CTF object must be a non-empty string."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : contains(["teams", "users"], ctf.user_mode)])
    error_message = "The 'user_mode' field must be either 'teams' or 'users'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : contains(["public", "private", "admins"], ctf.challenge_visibility)])
    error_message = "The 'challenge_visibility' field must be one of 'public', 'private', or 'admins'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : contains(["public", "private", "admins"], ctf.account_visibility)])
    error_message = "The 'account_visibility' field must be one of 'public', 'private', or 'admins'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : contains(["public", "private", "hidden", "admins"], ctf.score_visibility)])
    error_message = "The 'score_visibility' field must be one of 'public', 'private', 'hidden', or 'admins'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : contains(["public", "private", "Mmlc"], ctf.registration_visibility)])
    error_message = "The 'registration_visibility' field must be one of 'public', 'private', or 'Mmlc'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : alltrue([for b in ctf.brackets : contains(["", "users", "teams"], b.type)])])
    error_message = "The 'type' field in each bracket object must be either an empty string, 'users', or 'teams'."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.ctfd.secret_key) > 0])
    error_message = "The 'secret_key' field in the 'ctfd' object must be a non-empty string."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.db.user) > 0])
    error_message = "The 'user' field in the 'db' object must be a non-empty string."
  }

  validation {
    condition     = length(distinct([for ctf in var.ctfs : ctf.db.user])) == length(var.ctfs)
    error_message = "The 'user' field in the 'db' object must be unique across all CTF objects."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.db.password) > 0])
    error_message = "The 'password' field in the 'db' object must be a non-empty string."
  }

  validation {
    condition     = alltrue([for ctf in var.ctfs : length(ctf.redis.password) > 0])
    error_message = "The 'password' field in the 'redis' object must be a non-empty string."
  }
}
