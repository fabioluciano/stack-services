data "cloudflare_zones" "domain_zone" {
  name = var.domain_name
}

locals {
  zone_id = one(data.cloudflare_zones.domain_zone.result).id
}

module "dns" {
  source = "./dns"

  zone_id             = local.zone_id
  domain_name         = var.domain_name
  enable_github_pages = var.enable_github_pages
  enable_fastmail     = var.enable_fastmail
  fastmail_dav_id     = var.fastmail_dav_id
  redirect_rules      = var.redirect_rules
  custom_dns_records  = var.custom_dns_records
}

module "mail" {
  source = "./mail"

  zone_id                  = local.zone_id
  domain_name              = var.domain_name
  email_routing_dkim_value = var.email_routing_dkim_value
  email_routing_rules      = var.email_routing_rules
}
