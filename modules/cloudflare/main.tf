data "cloudflare_zones" "domain_zone" {
  name = var.domain_name
}

locals {
  github_records_to_process = var.enable_github_pages ? [
    for r_gh in var.github_pages_dns_records : {
      key_string : "${r_gh.record_type}__${var.domain_name}__${r_gh.value}",
      record_type : r_gh.record_type,
      proxied : false,
      content_val : r_gh.value,
      priority_val : null,
      record_actual_name : var.domain_name
    }
  ] : []

  google_workspace_records_to_process = var.enable_google_workspace ? [
    for r_mx in var.google_workspace_mx_records : {
      key_string : "${r_mx.record_type}__${var.domain_name}__${r_mx.value}",
      record_type : r_mx.record_type,
      content_val : r_mx.value,
      priority_val : r_mx.priority,
      record_actual_name : var.domain_name
    }
  ] : []

  custom_records_to_process = [
    for r_custom in var.custom_dns_records : {
      key_string : "${r_custom.type}__${r_custom.name}__${r_custom.value}",
      record_type : r_custom.type,
      proxied : r_custom.proxied,
      content_val : r_custom.value,
      priority_val : upper(r_custom.type) == "MX" ? r_custom.priority : null,
      record_actual_name : r_custom.name
    }
  ]

  all_dns_records_map = {
    for record_data in concat(local.github_records_to_process, local.google_workspace_records_to_process, local.custom_records_to_process) :
    md5(lower(record_data.key_string)) => {
      type     = upper(record_data.record_type)
      content  = record_data.content_val
      priority = record_data.priority_val
      name     = record_data.record_actual_name
      proxied  = try(record_data.proxied, false)
    }
  }
}

resource "cloudflare_dns_record" "all_records" {
  for_each = local.all_dns_records_map

  zone_id  = one(data.cloudflare_zones.domain_zone.result).id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  priority = each.value.priority
  proxied  = try(each.value.proxied, false)
  ttl      = 1
}
