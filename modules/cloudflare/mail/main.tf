locals {
  email_routing_mx_records = [
    { content = "route1.mx.cloudflare.net", priority = 43 },
    { content = "route2.mx.cloudflare.net", priority = 22 },
    { content = "route3.mx.cloudflare.net", priority = 91 },
  ]
}

resource "cloudflare_dns_record" "email_routing_mx" {
  for_each = length(var.email_routing_rules) > 0 ? {
    for mx in local.email_routing_mx_records : mx.content => mx
  } : {}

  zone_id  = var.zone_id
  name     = var.domain_name
  type     = "MX"
  content  = each.value.content
  priority = each.value.priority
  ttl      = 1
}

resource "cloudflare_dns_record" "email_routing_spf" {
  count = length(var.email_routing_rules) > 0 ? 1 : 0

  zone_id = var.zone_id
  name    = var.domain_name
  type    = "TXT"
  content = "v=spf1 include:_spf.mx.cloudflare.net ~all"
  ttl     = 1
}

resource "cloudflare_dns_record" "email_routing_dkim" {
  count = var.email_routing_dkim_value != null ? 1 : 0

  zone_id = var.zone_id
  name    = "cf2024-1._domainkey.${var.domain_name}"
  type    = "TXT"
  content = "v=DKIM1; h=sha256; k=rsa; p=${var.email_routing_dkim_value}"
  ttl     = 1

  lifecycle {
    ignore_changes = [content]
  }
}

resource "cloudflare_email_routing_rule" "rules" {
  for_each = {
    for rule in var.email_routing_rules : rule.from => rule
  }

  zone_id = var.zone_id
  name    = "Forward ${each.key} to ${join(", ", each.value.to)}"
  enabled = true

  matchers = [{
    type  = "literal"
    field = "to"
    value = each.key
  }]

  actions = [{
    type  = "forward"
    value = each.value.to
  }]
}
