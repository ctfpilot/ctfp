# ----------------------
# DNS
# ----------------------

locals {
  management_dns = "${var.cluster_dns_management}"
  management_dns_subdomain = replace(var.cluster_dns_management, "${var.cloudflare_dns_management}", "")
  management_dns_should_proxy = length(split(".", local.management_dns_subdomain)) <= 2 ? true : false
  management_dns_wildcard = "*.${var.cluster_dns_management}"
  management_dns_wildcard_should_proxy = length(split(".", local.management_dns_subdomain)) < 2 ? true : false

  platform_dns   = "${var.cluster_dns_platform}"
  platform_dns_subdomain = replace(var.cluster_dns_platform, "${var.cloudflare_dns_platform}", "")
  platform_dns_should_proxy = length(split(".", local.platform_dns_subdomain)) <= 2 ? true : false
  platform_dns_wildcard = "*.${var.cluster_dns_platform}"
  platform_dns_wildcard_should_proxy = length(split(".", local.platform_dns_subdomain)) < 2 ? true : false

  ctf_dns        = "${var.cluster_dns_ctf}"
  ctf_dns_subdomain = replace(var.cluster_dns_ctf, "${var.cloudflare_dns_ctf}", "")
  ctf_dns_should_proxy = length(split(".", local.ctf_dns_subdomain)) <= 2 ? true : false
  ctf_dns_wildcard = "*.${var.cluster_dns_ctf}"
  ctf_dns_wildcard_should_proxy = length(split(".", local.ctf_dns_subdomain)) < 2 ? true : false
}

data "cloudflare_zones" "domain_name_zone_management" {
  filter {
    name = var.cloudflare_dns_management
  }
}

# Create DNS A record
resource "cloudflare_record" "domain_name_management" {
  zone_id = data.cloudflare_zones.domain_name_zone_management.zones.0.id
  name    = local.management_dns
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = local.management_dns_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_management,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_management" {
  zone_id = data.cloudflare_zones.domain_name_zone_management.zones.0.id
  name    = local.management_dns_wildcard
  content = var.cluster_dns_management
  type    = "CNAME"
  ttl     = 1
  proxied = local.management_dns_wildcard_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_management,
  ]
}

data "cloudflare_zones" "domain_name_zone_ctf" {
  filter {
    name = var.cloudflare_dns_ctf
  }
}

# Create DNS A record
resource "cloudflare_record" "domain_name_ctf" {
  zone_id = data.cloudflare_zones.domain_name_zone_ctf.zones.0.id
  name    = local.ctf_dns
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = local.ctf_dns_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_ctf,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_ctf" {
  zone_id = data.cloudflare_zones.domain_name_zone_ctf.zones.0.id
  name    = local.ctf_dns_wildcard
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = local.ctf_dns_wildcard_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_ctf,
  ]
}

data "cloudflare_zones" "domain_name_zone_platform" {
  filter {
    name = var.cloudflare_dns_platform
  }
}

# Create DNS A record
resource "cloudflare_record" "domain_name_platform" {
  zone_id = data.cloudflare_zones.domain_name_zone_platform.zones.0.id
  name    = local.platform_dns
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = local.platform_dns_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_platform,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_platform" {
  zone_id = data.cloudflare_zones.domain_name_zone_platform.zones.0.id
  name    = local.platform_dns_wildcard
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = local.platform_dns_wildcard_should_proxy

  depends_on = [
    data.cloudflare_zones.domain_name_zone_platform,
  ]
}
