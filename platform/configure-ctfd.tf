# Wait for the CTFd URL to be reachable
resource "null_resource" "wait_for_url" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOT
      for i in {1..50}; do
        echo "Checking if ${var.cluster_dns_platform} is reachable (attempt $i)..."
        if curl --silent --head --fail https://${var.cluster_dns_platform}/setup; then
          echo "CTFd is reachable!"
          if curl --silent --head --fail https://ctfd-manager.${var.cluster_dns_management}/api/status; then
            echo "Manager is reachable!"
            exit 0
          fi
          echo "Manager is not reachable yet, retrying..."
        fi
        sleep 10
      done
      echo "Timeout waiting for CTFd and manager to be reachable."
      exit 1
    EOT
  }

  depends_on = [
    module.ctfd-ingress,
    module.argocd-ctfd,
    module.ctfd-manager-ingress
  ]
}

# Configure CTFd through manager using local-exec
locals {
  configure_ctfd_payload = {
    ctf_name                = var.ctf_name
    ctf_description         = var.ctf_description
    user_mode               = var.ctf_user_mode
    challenge_visibility    = var.ctf_challenge_visibility
    account_visibility      = var.ctf_account_visibility
    score_visibility        = var.ctf_score_visibility
    registration_visibility = var.ctf_registration_visibility
    verify_emails           = var.ctf_verify_emails
    ctf_theme               = var.ctf_theme
    name                    = var.ctf_admin_name
    email                   = var.ctf_admin_email
    password                = var.ctf_admin_password
    start                   = var.ctf_start_time != "" ? var.ctf_start_time : null
    end                     = var.ctf_end_time != "" ? var.ctf_end_time : null
    ctf_team_size           = var.ctf_team_size > 0 ? var.ctf_team_size : null
    brackets                = length(var.ctf_brackets) > 0 ? var.ctf_brackets : null
    mail_server             = var.ctf_mail_server
    mail_port               = var.ctf_mail_port
    mail_username           = var.ctf_mail_username
    mail_password           = var.ctf_mail_password
    mail_tls                = var.ctf_mail_tls
    mail_from               = var.ctf_mail_from
    registration_code       = var.ctf_registration_code
    ctf_logo = {
      name = "logo.png"
      data = base64encode(filebase64("${path.module}/${var.ctf_logo_path}"))
    }
  }
} 

# Write payload to local file
resource "local_file" "ctfd_config" {
  content  = jsonencode(local.configure_ctfd_payload)
  filename = "${path.module}/ctfd_config.json"

  depends_on = [
    null_resource.wait_for_url,
    module.ctfd-ingress,
    module.ctfd-manager-ingress,
  ]
}

resource "null_resource" "configure-ctfd" {
  depends_on = [
    null_resource.wait_for_url,
    module.ctfd-ingress,
    module.ctfd-manager-ingress,
	local_file.ctfd_config,
  ]

  provisioner "local-exec" {
    command     = <<EOT
	  echo "Configuring CTFd through manager..."
      curl -sSL -X POST \
        -H "Authorization: Bearer ${var.ctfd_manager_password}" \
        -H "Content-Type: application/json" \
        --data-binary "@${path.module}/ctfd_config.json" \
        "https://ctfd-manager.${var.cluster_dns_management}/api/ctfd/setup"
      rm "${path.module}/ctfd_config.json"
    EOT
    interpreter = ["bash", "-c"]
    # on_failure  = continue
  }

  lifecycle {
    ignore_changes = [

    ]
  }
}
