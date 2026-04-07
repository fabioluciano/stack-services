variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "email_routing_dkim_value" {
  description = "DKIM public key value for Cloudflare Email Routing (the 'p=' part)"
  type        = string
  default     = null
}

variable "email_routing_rules" {
  description = "List of email routing forwarding rules"
  type = list(object({
    from = string
    to   = list(string)
  }))
  default = []
}
