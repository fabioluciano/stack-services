variable "cloudflare_api_key" {
  description = "Cloudflare API key"
  type        = string
}
variable "cloudflare_email" {
  description = "Cloudflare email"
  type        = string
}

variable "github_pages_dns_records" {
  description = "GitHub Pages DNS records"
  type = list(object({
    record_type = string
    value       = string
  }))

  validation {
    condition = alltrue([
      for record in var.github_pages_dns_records : contains(["A", "AAAA"], upper(record.record_type))
    ])
    error_message = "Invalid record_type for github_pages_dns_records. Allowed types are A, AAAA."
  }
}

variable "google_workspace_mx_records" {
  description = "Google Workspace MX records"
  type = list(object({
    record_type = optional(string, null)
    value       = optional(string, null)
    priority    = optional(number, null)
  }))

  default = []

  validation {
    condition = alltrue([
      for record in var.google_workspace_mx_records : upper(record.record_type) == "MX"
    ])
    error_message = "Invalid record_type for google_workspace_mx_records. All records must be of type MX."
  }
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "enable_github_pages" {
  description = "Enable GitHub Pages"
  type        = bool
  default     = false
}

variable "enable_google_workspace" {
  description = "Enable Google Workspace"
  type        = bool
  default     = false
}

variable "custom_dns_records" {
  description = "Custom DNS records"
  type = list(object({
    type     = string
    name     = string
    value    = string
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
