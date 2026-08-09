variable "ctfs" {
  type = list(object({
    slug      = string # Slug for the CTF event. This will be used in internal namings and must be unique. It should be a lowercase string with no spaces or special characters.
    subdomain = string # A subdomain to the `cluster_dns_platform`, or empty string if you want to use the `cluster_dns_platform` directly. This will be used to generate the CTF URL.
  }))

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
}
