variable "namespace" {
  type        = string
  description = "Namespace where the MariaDB cluster will be deployed"
  nullable    = false
}

variable "cluster_name" {
  type        = string
  description = "Name of the MariaDB cluster"
  nullable    = false
}

variable "root_password" {
  type        = string
  description = "Root password for the MariaDB cluster"
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

variable "mariadb_version" {
  type        = string
  description = "The version of MariaDB deploy. More information at https://github.com/mariadb-operator/mariadb-operator"
  nullable    = false
}

variable "timezone" {
  type        = string
  description = "A UTC offset (e.g. \"+2:00\") or a named zone (e.g. \"Europe/Copenhagen\", which is DST-aware unlike a fixed offset). Used as both the MariaDB cluster's timeZone (immutable after cluster creation - changing it on an existing cluster will fail) and the Backup resource's cron schedule timezone (mutable, takes effect on the next scheduled run)."
  nullable    = false
  default     = "UTC"
}
