# ----------------------
# DNS
# ----------------------

data "cloudflare_zones" "domain_name_zone_management" {
  filter {
    name = var.cloudflare_dns_management
  }
}

# Create DNS A record
resource "cloudflare_record" "domain_name_management" {
  zone_id = data.cloudflare_zones.domain_name_zone_management.zones.0.id
  name    = var.cluster_dns_management
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1

  depends_on = [
    data.cloudflare_zones.domain_name_zone_management,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_management" {
  zone_id = data.cloudflare_zones.domain_name_zone_management.zones.0.id
  name    = "*.${var.cluster_dns_management}"
  content = var.cluster_dns_management
  type    = "CNAME"
  ttl     = 1

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
  name    = var.cluster_dns_ctf
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = true

  depends_on = [
    data.cloudflare_zones.domain_name_zone_ctf,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_ctf" {
  zone_id = data.cloudflare_zones.domain_name_zone_ctf.zones.0.id
  name    = "*.${var.cluster_dns_ctf}"
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = false

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
  name    = var.cluster_dns_platform
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = true

  depends_on = [
    data.cloudflare_zones.domain_name_zone_platform,
  ]
}

# Create DNS A wildcard record
resource "cloudflare_record" "wildcard_domain_name_platform" {
  zone_id = data.cloudflare_zones.domain_name_zone_platform.zones.0.id
  name    = "*.${var.cluster_dns_platform}"
  content = module.kube-hetzner.ingress_public_ipv4
  type    = "A"
  ttl     = 1
  proxied = true

  depends_on = [
    data.cloudflare_zones.domain_name_zone_platform,
  ]
}
