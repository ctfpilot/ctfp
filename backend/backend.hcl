# BACKEND CONFIGURATION TEMPLATE FOR TERRAFORM
# This file is a template for the backend configurations located in the `generated` directory.

key = "%%KEY%%"

bucket = "%%S3_BUCKET%%"
region = "%%S3_REGION%%"
endpoints = {
  s3 = "%%S3_ENDPOINT%%"
}

workspace_key_prefix = "state/%%COMPONENT%%"

# The following settings are to skip various
# aws related checks and validation
# which is not possible when using third party s3 compatible storage
skip_region_validation      = true
skip_credentials_validation = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true

skip_s3_checksum = false
use_path_style   = false
