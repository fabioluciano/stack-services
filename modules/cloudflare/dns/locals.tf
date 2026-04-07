locals {
  has_apex_redirect = anytrue([for rule in var.redirect_rules : rule.from == var.domain_name])

  fastmail_root_a_records = !local.has_apex_redirect ? [
    { type = "A", name = "@", value = "103.168.172.37", ttl = 3600 },
    { type = "A", name = "@", value = "103.168.172.52", ttl = 3600 },
  ] : []

  redirect_dns_records = [
    for rule in var.redirect_rules : {
      type    = "A"
      name    = rule.from == var.domain_name ? "@" : trimsuffix(rule.from, ".${var.domain_name}")
      value   = "192.0.2.1"
      ttl     = 1
      proxied = true
    }
  ]

  # GitHub Pages DNS records
  github_pages_dns_records = var.enable_github_pages ? [
    { type = "A", name = "@", value = "185.199.108.153", ttl = 1 },
    { type = "A", name = "@", value = "185.199.109.153", ttl = 1 },
    { type = "A", name = "@", value = "185.199.110.153", ttl = 1 },
    { type = "A", name = "@", value = "185.199.111.153", ttl = 1 },
    { type = "AAAA", name = "@", value = "2606:50c0:8000::153", ttl = 1 },
    { type = "AAAA", name = "@", value = "2606:50c0:8001::153", ttl = 1 },
    { type = "AAAA", name = "@", value = "2606:50c0:8002::153", ttl = 1 },
    { type = "AAAA", name = "@", value = "2606:50c0:8003::153", ttl = 1 },
    { type = "CNAME", name = "www", value = "${var.domain_name}", ttl = 1 },
  ] : []

  # Fastmail DNS records (non-SRV)
  fastmail_dns_records = var.enable_fastmail ? concat(
    [
      # Root MX
      { type = "MX", name = "@", value = "in1-smtp.messagingengine.com", ttl = 1, priority = 10 },
      { type = "MX", name = "@", value = "in2-smtp.messagingengine.com", ttl = 1, priority = 20 },
    ],
    local.fastmail_root_a_records,
    [
      # SPF
      { type = "TXT", name = "@", value = "v=spf1 include:spf.messagingengine.com ?all", ttl = 1 },

      # Wildcard MX
      { type = "MX", name = "*", value = "in1-smtp.messagingengine.com", ttl = 3600, priority = 10 },
      { type = "MX", name = "*", value = "in2-smtp.messagingengine.com", ttl = 3600, priority = 20 },

      # DMARC
      { type = "TXT", name = "_dmarc", value = "v=DMARC1; p=none;", ttl = 3600 },

      # DKIM CNAME (domain interpolated)
      { type = "CNAME", name = "fm1._domainkey", value = "fm1.${var.domain_name}.dkim.fmhosted.com", ttl = 1 },
      { type = "CNAME", name = "fm2._domainkey", value = "fm2.${var.domain_name}.dkim.fmhosted.com", ttl = 1 },
      { type = "CNAME", name = "fm3._domainkey", value = "fm3.${var.domain_name}.dkim.fmhosted.com", ttl = 1 },
      { type = "CNAME", name = "mesmtp._domainkey", value = "mesmtp.${var.domain_name}.dkim.fmhosted.com", ttl = 3600 },

      # mail subdomain
      { type = "MX", name = "mail", value = "in1-smtp.messagingengine.com", ttl = 3600, priority = 10 },
      { type = "MX", name = "mail", value = "in2-smtp.messagingengine.com", ttl = 3600, priority = 20 },
      { type = "A", name = "mail", value = "103.168.172.65", ttl = 3600 },
    ]
  ) : []

  # Fastmail SRV records
  fastmail_srv_records = var.enable_fastmail ? [
    { name = "_autodiscover._tcp", ttl = 3600, priority = 0, weight = 1, port = 443, target = "autodiscover.fastmail.com" },
    { name = "_caldav._tcp", ttl = 3600, priority = 0, weight = 0, port = 0, target = "." },
    { name = "_caldavs._tcp", ttl = 3600, priority = 0, weight = 1, port = 443, target = "${var.fastmail_dav_id}.caldav.fastmail.com" },
    { name = "_carddav._tcp", ttl = 3600, priority = 0, weight = 0, port = 0, target = "." },
    { name = "_carddavs._tcp", ttl = 3600, priority = 0, weight = 1, port = 443, target = "${var.fastmail_dav_id}.carddav.fastmail.com" },
    { name = "_imap._tcp", ttl = 3600, priority = 0, weight = 0, port = 0, target = "." },
    { name = "_imaps._tcp", ttl = 3600, priority = 0, weight = 1, port = 993, target = "imap.fastmail.com" },
    { name = "_jmap._tcp", ttl = 3600, priority = 0, weight = 1, port = 443, target = "api.fastmail.com" },
    { name = "_pop3._tcp", ttl = 3600, priority = 0, weight = 0, port = 0, target = "." },
    { name = "_pop3s._tcp", ttl = 3600, priority = 10, weight = 1, port = 995, target = "pop.fastmail.com" },
    { name = "_submission._tcp", ttl = 3600, priority = 0, weight = 0, port = 0, target = "." },
    { name = "_submissions._tcp", ttl = 3600, priority = 0, weight = 1, port = 465, target = "smtp.fastmail.com" },
  ] : []

  records_to_process = [
    for r in concat(var.custom_dns_records, local.github_pages_dns_records, local.fastmail_dns_records, local.redirect_dns_records) : {
      key_string         = "${r.type}__${r.name}__${r.value}"
      record_type        = r.type
      proxied            = try(r.proxied, false)
      content_val        = r.value
      ttl_val            = try(r.ttl, 1)
      priority_val       = contains(["MX", "SRV", "URI"], upper(r.type)) ? r.priority : null
      record_actual_name = r.name
    }
  ]

  all_dns_records_map = {
    for record_data in local.records_to_process :
    md5(lower(record_data.key_string)) => {
      type     = upper(record_data.record_type)
      content  = record_data.content_val
      ttl      = record_data.ttl_val
      priority = record_data.priority_val
      name     = record_data.record_actual_name
      proxied  = record_data.proxied
    }
  }

  fastmail_srv_records_map = {
    for r_srv in local.fastmail_srv_records :
    md5(lower("SRV__${r_srv.name}__${r_srv.target}__${r_srv.port}")) => r_srv
  }
}
