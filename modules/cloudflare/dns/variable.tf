variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "enable_github_pages" {
  description = "Enable GitHub Pages DNS records"
  type        = bool
  default     = false
}

variable "enable_fastmail" {
  description = "Enable Fastmail DNS records"
  type        = bool
  default     = false
}

variable "fastmail_dav_id" {
  description = "Fastmail DAV identifier for caldav/carddav SRV records"
  type        = string
  default     = null
}

variable "redirect_rules" {
  description = "List of redirect rules (from hostname to target URL)"
  type = list(object({
    from          = string
    to            = string
    status_code   = optional(number, 301)
    preserve_path = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.redirect_rules : can(regex("^https?://", rule.to))
    ])
    error_message = "Each redirect rule 'to' must start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for rule in var.redirect_rules : contains([301, 302, 303, 307, 308], rule.status_code)
    ])
    error_message = "status_code must be one of: 301, 302, 303, 307, 308."
  }
}

variable "custom_dns_records" {
  description = "Custom DNS records"
  type = list(object({
    type     = string
    name     = string
    value    = string
    ttl      = optional(number, 1)
    proxied  = optional(bool, false)
    priority = optional(number, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for record in var.custom_dns_records : contains(["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "CAA", "NS", "PTR", "SPF", "URI"], upper(record.type))
    ])
    error_message = "Invalid record_type for custom_dns_records. Allowed types are A, AAAA, CNAME, MX, TXT, SRV, CAA, NS, PTR, SPF, URI."
  }

  validation {
    condition = alltrue([
      for record in var.custom_dns_records :
      (upper(record.type) == "MX" ? record.priority != null : true)
    ])
    error_message = "Priority must be provided and cannot be null for MX records in custom_dns_records."
  }
}
