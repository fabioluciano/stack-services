resource "cloudflare_dns_record" "all_records" {
  for_each = local.all_dns_records_map

  zone_id  = var.zone_id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  priority = each.value.priority
  proxied  = each.value.proxied
}

resource "cloudflare_dns_record" "srv_records" {
  for_each = local.fastmail_srv_records_map

  zone_id  = var.zone_id
  name     = each.value.name
  type     = "SRV"
  ttl      = each.value.ttl
  priority = each.value.priority

  data = {
    priority = each.value.priority
    weight   = each.value.weight
    port     = each.value.port
    target   = each.value.target
  }
}

resource "cloudflare_ruleset" "redirect" {
  count = length(var.redirect_rules) > 0 ? 1 : 0

  zone_id     = var.zone_id
  name        = "default"
  description = "Redirect rules"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    for rule in var.redirect_rules : {
      ref         = "redirect_${md5(rule.from)}"
      description = "Redirect ${rule.from} to ${rule.to}"
      expression  = format("http.host eq \"%s\"", rule.from)
      action      = "redirect"
      enabled     = true
      action_parameters = {
        from_value = {
          status_code = rule.status_code
          target_url = rule.preserve_path ? {
            expression = format("concat(\"%s\", http.request.uri.path)", trimsuffix(rule.to, "/"))
            } : {
            value = rule.to
          }
          preserve_query_string = true
        }
      }
    }
  ]
}
