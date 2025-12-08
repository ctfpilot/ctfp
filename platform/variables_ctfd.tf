variable "ctf_name" {
  description = "Name of the CTF event"
  type        = string
}

variable "ctf_description" {
  description = "Description of the CTF event"
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
  description = "User mode for CTFd (e.g., 'teams')"
  type        = string
  validation {
    condition     = contains(["teams", "users"], var.ctf_user_mode)
    error_message = "ctf_user_mode must be either 'teams' or 'users'."
  }
}

variable "ctf_challenge_visibility" {
  description = "Challenge visibility (e.g., 'public')"
  type        = string
  validation {
    condition     = contains(["public", "private", "admins"], var.ctf_challenge_visibility)
    error_message = "ctf_challenge_visibility must be either 'public', 'private', or 'admins'."
  }
}

variable "ctf_account_visibility" {
  description = "Account visibility (e.g., 'private')"
  type        = string
  validation {
    condition     = contains(["public", "private", "admins"], var.ctf_account_visibility)
    error_message = "ctf_account_visibility must be either 'public', 'private', or 'admins'."
  }
}

variable "ctf_score_visibility" {
  description = "Score visibility (e.g., 'public')"
  type        = string
  validation {
    condition     = contains(["public", "private", "hidden", "admins"], var.ctf_score_visibility)
    error_message = "ctf_score_visibility must be either 'public', 'private', 'hidden', or 'admins'."
  }
}

variable "ctf_registration_visibility" {
  description = "Registration visibility (e.g., 'public')"
  type        = string
  validation {
    condition     = contains(["public", "private", "Mmlc"], var.ctf_registration_visibility)
    error_message = "ctf_registration_visibility must be either 'public', 'private', or 'Mmlc'."
  }
}

variable "ctf_verify_emails" {
  description = "Whether to verify emails"
  type        = bool
  default     = true
}

variable "ctf_team_size" {
  description = "Team size for the CTF. 0 means no limit"
  type        = number
  default     = 5
}

variable "ctf_brackets" {
  description = "List of brackets for the CTF (optional)"
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
  description = "Theme for CTFd"
  type        = string
  default     = "core-kubectf"
}

variable "ctf_admin_name" {
  description = "Name of the admin user"
  type        = string
}

variable "ctf_admin_email" {
  description = "Email of the admin user"
  type        = string
}

variable "ctf_admin_password" {
  description = "Password for the admin user"
  type        = string
  sensitive   = true
}

variable "ctf_registration_code" {
  description = "Registration code for the CTF"
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
