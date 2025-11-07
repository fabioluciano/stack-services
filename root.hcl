generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket = "infra-state"
    key    = "${path_relative_to_include()}/infra.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key = "${get_env("CLOUDFLARE_R2_ACCESS_KEY")}"
    secret_key = "${get_env("CLOUDFLARE_R2_SECRET_KEY")}"
    endpoints = { s3 = "${get_env("CLOUDFLARE_R2_ENDPOINT")}" }
  }
}
EOF
}

locals {
  default_github_pages_dns_records = [
    { record_type = "A", value = "185.199.108.153" },
    { record_type = "A", value = "185.199.109.153" },
    { record_type = "A", value = "185.199.110.153" },
    { record_type = "A", value = "185.199.111.153" },
    { record_type = "AAAA", value = "2606:50c0:8000::153" },
    { record_type = "AAAA", value = "2606:50c0:8001::153" },
    { record_type = "AAAA", value = "2606:50c0:8002::153" },
    { record_type = "AAAA", value = "2606:50c0:8003::153" }
  ]

  default_google_workspace_mx_records = [
    { record_type = "MX", value = "aspmx.l.google.com", priority = 1 },
    { record_type = "MX", value = "alt1.aspmx.l.google.com", priority = 5 },
    { record_type = "MX", value = "alt2.aspmx.l.google.com", priority = 5 },
    { record_type = "MX", value = "alt3.aspmx.l.google.com", priority = 10 },
    { record_type = "MX", value = "alt4.aspmx.l.google.com", priority = 10 }
  ]
}

inputs = {
  default_github_pages_dns_records    = local.default_github_pages_dns_records
  default_google_workspace_mx_records = local.default_google_workspace_mx_records
}