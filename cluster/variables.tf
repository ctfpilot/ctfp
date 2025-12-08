# ----------------------
# Variables
# ----------------------

# Hetzner
variable "hcloud_token" {
  sensitive   = true
  description = "Hetzner cloud project token (obtained from a specific project in Hetzner cloud)"
}

# SSH
variable "ssh_key_private_base64" {
  sensitive   = true
  description = "The private key to use for SSH access to the servers (base64 encoded)"
}

variable "ssh_key_public_base64" {
  description = "The public key to use for SSH access to the servers (base64 encoded)"
}

# Cloudflare & DNS variables
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

variable "cluster_dns_platform" {
  type        = string
  description = "The domain name to use for the DNS records for the platform part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_platform`"
}

variable "cluster_dns_ctf" {
  type        = string
  description = "The domain name to use for the DNS records for the CTF challenges part of the cluster. Must be the TLD or subdomain of `cloudflare_dns_ctf`"
}

# Cluster configuration
variable "region_1" {
  type        = string
  description = "Region to deploy nodes in subgroup 1"
  default     = "fsn1"
  validation {
    condition     = contains(["fsn1", "hel1", "nbg1"], var.region_1)
    error_message = "Region must be one of fsn1, hel1, or nbg1."
  }
}

variable "region_2" {
  type        = string
  description = "Region to deploy nodes in subgroup 2"
  default     = "fsn1"
  validation {
    condition     = contains(["fsn1", "hel1", "nbg1"], var.region_2)
    error_message = "Region must be one of fsn1, hel1, or nbg1."
  }
}

variable "region_3" {
  type        = string
  description = "Region to deploy nodes in subgroup 3"
  default     = "fsn1"
  validation {
    condition     = contains(["fsn1", "hel1", "nbg1", "ash", "hil", "sin"], var.region_3)
    error_message = "Region must be one of fsn1, hel1, or nbg1."
  }
}

variable "network_zone" {
  type        = string
  description = "The Hetzner network zone to deploy the cluster in"
  default     = "eu-central"
  validation {
    condition     = contains(["eu-central", "us-east", "us-west", "ap-southeast"], var.network_zone)
    error_message = "Network zone must be one of eu-central or us-west."
  }
}

variable "control_plane_type_1" {
  type        = string
  description = "Control plane group 1 server type"
  default     = "cx32"
}

variable "control_plane_type_2" {
  type        = string
  description = "Control plane group 2 server type"
  default     = "cx32"
}

variable "control_plane_type_3" {
  type        = string
  description = "Control plane group 3 server type"
  default     = "cx32"
}

variable "agent_type_1" {
  type        = string
  description = "Agent group 1 server type"
  default     = "cx32"
}

variable "agent_type_2" {
  type        = string
  description = "Agent group 2 server type"
  default     = "cx32"
}

variable "agent_type_3" {
  type        = string
  description = "Agent group 3 server type"
  default     = "cx32"
}

variable "scale_type" {
  type        = string
  description = "Scale group server type"
  default     = "cx32"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balancer type"
  default     = "lb11"
  validation {
    condition     = contains(["lb11", "lb21", "lb31"], var.load_balancer_type)
    error_message = "Load balancer type must be one of lb11, lb21, or lb31."
  }
}

variable "control_plane_count_1" {
  type        = number
  description = "Number of control plane nodes in group 1"
  default     = 1
  validation {
    condition     = var.control_plane_count_1 >= 0
    error_message = "Control plane count must be at least 0."
  }
}

variable "control_plane_count_2" {
  type        = number
  description = "Number of control plane nodes in group 2"
  default     = 1
  validation {
    condition     = var.control_plane_count_2 >= 0
    error_message = "Control plane count must be at least 0."
  }
}

variable "control_plane_count_3" {
  type        = number
  description = "Number of control plane nodes in group 3"
  default     = 1
  validation {
    condition     = var.control_plane_count_3 >= 0
    error_message = "Control plane count must be at least 0."
  }
}

variable "agent_count_1" {
  type        = number
  description = "Number of agent nodes in group 1"
  default     = 1
  validation {
    condition     = var.agent_count_1 >= 0
    error_message = "Agent count must be at least 0."
  }
}

variable "agent_count_2" {
  type        = number
  description = "Number of agent nodes in group 2"
  default     = 1
  validation {
    condition     = var.agent_count_2 >= 0
    error_message = "Agent count must be at least 0."
  }
}

variable "agent_count_3" {
  type        = number
  description = "Number of agent nodes in group 3"
  default     = 1
  validation {
    condition     = var.agent_count_3 >= 0
    error_message = "Agent count must be at least 0."
  }
}

variable "challs_count" {
  type        = number
  description = "Number of CTF challenge nodes"
  default     = 0
  validation {
    condition     = var.challs_count >= 0
    error_message = "CTF challenge count must be at least 0."
  }
}

variable "scale_max" {
  type        = number
  description = "Maximum number of scale nodes. Set to 0 to disable autoscaling (default: 0)"
  default     = 0
  validation {
    condition     = var.scale_max >= 0
    error_message = "Scale max must be at least 0."
  }
}
